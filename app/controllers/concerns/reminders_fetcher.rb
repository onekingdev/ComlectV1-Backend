# frozen_string_literal: true

module RemindersFetcher
  class FakeTask
    def initialize(id)
      self.id = id
      self.body = nil
    end
    attr_accessor :id, :body
  end

  def tasks_for_object(object)
    return [] if object.reminders.count.zero?
    @grid_tasks = object.reminders.where(repeats: nil)
    @recurring_tasks = object.reminders.where.not(repeats: nil)
    first_day = object.reminders.collect(&:remind_at).compact.min
    calendar_grid = populate_recurring_tasks2(@recurring_tasks, first_day, first_day + 1.year)
    (calendar_grid + @grid_tasks).sort_by(&:end_date)
  end

  def tasks_calendar_grid2(remindable, first_day, last_day)
    @grid_tasks = Reminder.where('end_date >= ? AND remind_at < ?', first_day, last_day).where(assignee: remindable).where(repeats: nil)
                          .or(Reminder.where('end_date >= ? AND remind_at < ?', first_day, last_day).where(repeats: nil, remindable: remindable))
    if remindable.class.to_s == 'Business'
      @grid_tasks = @grid_tasks.or(Reminder.where(business_id: remindable.id))
    end
    @recurring_tasks = Reminder.where('remind_at < ?', last_day).where(assignee: remindable).where.not(repeats: nil).or(Reminder.where('remind_at < ?', last_day).where(remindable: remindable).where.not(repeats: nil))
    @active_projects = remindable.local_projects.where.not(id: remindable.user.hidden_local_projects)
    calendar_grid = populate_recurring_tasks2(@recurring_tasks, first_day, last_day)
    [(calendar_grid + @grid_tasks).sort_by(&:end_date), @active_projects]
  end

  def upcoming_tab(remindable, first_day, last_day)
    @grid_tasks = Reminder.where('remind_at BETWEEN ? AND ?', first_day, last_day).where(assignee: remindable).where(repeats: nil)
                          .or(Reminder.where('remind_at BETWEEN ? AND ?', first_day, last_day).where(repeats: nil, remindable: remindable))
    if remindable.class.to_s == 'Business'
      @grid_tasks = @grid_tasks.or(Reminder.where('remind_at BETWEEN ? AND ?', first_day, last_day).where(business_id: remindable.id))
    end

    @active_projects = if remindable.class.to_s != 'Business'
      remindable.projects.where('starts_on BETWEEN ? AND ?', first_day, last_day)
    else
      remindable.local_projects.where('starts_on BETWEEN ? AND ?', first_day, last_day).where.not(id: remindable.user.hidden_local_projects)
    end
    [@grid_tasks.sort_by(&:end_date), @active_projects]
  end

  def tasks_calendar_grid(remindable, beginning)
    end_of_month = beginning + 40.days
    first_day = beginning - beginning.wday.days
    last_day = end_of_month + (6 - end_of_month.wday).days
    @grid_tasks = Reminder.where('end_date >= ? AND remind_at < ?', first_day, last_day).where(repeats: nil, remindable: remindable).or(Reminder.where('end_date >= ? AND remind_at < ?', first_day, last_day).where(repeats: nil, assignee: remindable))
    @recurring_tasks = Reminder.where('remind_at < ?', last_day).where(remindable: remindable).where.not(repeats: nil).or(Reminder.where('remind_at < ?', last_day).where(assignee: remindable).where.not(repeats: nil))
    @active_projects = remindable.projects
    calendar_grid = {}
    (first_day..last_day).each do |cell|
      calendar_grid[cell] = []
    end

    @active_projects.each do |task|
      next unless task.starts_on.present? && task.ends_on.present?
      (task.starts_on..task.ends_on).each do |d|
        calendar_grid[d].push(task) if calendar_grid.include?(d)
      end
    end

    @grid_tasks.each do |task|
      (task.remind_at..task.end_date).each do |d|
        calendar_grid[d].push(task) if calendar_grid.include?(d)
      end
    end

    calendar_grid = populate_recurring_tasks(@recurring_tasks, last_day, calendar_grid)

    prev_day = nil
    calendar_grid.keys.each do |date|
      if prev_day.nil?
        prev_day = date
      else
        # fantastic sorting
        safe_arr = []
        additive_arr = []
        calendar_grid[date].each do |task|
          next unless task.id != 0
          prev_task_index = calendar_grid[prev_day].collect(&:id).index(task.id)
          !prev_task_index.nil? ? safe_arr[prev_task_index] = task : additive_arr.push(task)
        end
        safe_arr.each_with_index do |a, i|
          safe_arr[i] = additive_arr.shift if a.nil?
        end
        unless additive_arr.empty?
          additive_arr.each do |a|
            safe_arr.push(a)
          end
        end
        safe_arr.each_with_index { |a, i| safe_arr[i] = FakeTask.new(0) if a.nil? }
        calendar_grid[date] = safe_arr
        prev_day = prev_day.wday == 6 ? nil : date
      end
    end
    calendar_grid
  end

  def populate_calendar(date_cursor, task, occurence_idx, calendar_grid)
    recurring_reminder = RecurringReminder.new(task, "#{task.id}_#{occurence_idx}", date_cursor)
    (date_cursor..(date_cursor + (task.duration - 1).days)).each do |d|
      calendar_grid[d].push(recurring_reminder) if calendar_grid.key?(d)
    end
    calendar_grid
  end

  # rubocop:disable Metrics/BlockNesting
  def populate_recurring_tasks2(tasks, first_day, last_day)
    output_tasks = []
    tasks.each do |task|
      occurence_idx = 0
      date_cursor = task.remind_at
      while (task.end_by.blank? || (task.end_by.present? && (date_cursor < task.end_by))) && (date_cursor < last_day)
        if %w[Daily Weekly Monthly Yearly].include?(task.repeats)
          unless (task.skip_occurencies.presence || [])&.include?(occurence_idx)
            output_tasks.push(RecurringReminder.new(task, "#{task.id}_#{occurence_idx}", date_cursor)) if date_cursor >= first_day
          end
          occurence_idx += 1
        end
        date_cursor = task.repeats == '' ? last_day : task.next_occurence(date_cursor)
      end
    end
    output_tasks
  end
  # rubocop:enable Metrics/BlockNesting

  def populate_recurring_tasks(tasks, last_day, calendar_grid)
    tasks.each do |task|
      occurence_idx = 0
      date_cursor = task.remind_at
      while (task.end_by.blank? || (task.end_by.present? && (date_cursor < task.end_by))) && (date_cursor < last_day)
        if %w[Daily Weekly Monthly Yearly].include?(task.repeats)
          unless (task.skip_occurencies.presence || [])&.include?(occurence_idx)
            calendar_grid = populate_calendar(date_cursor, task, occurence_idx, calendar_grid)
          end
          occurence_idx += 1
        end
        date_cursor = task.repeats == '' ? last_day : task.next_occurence(date_cursor)
      end
    end
    calendar_grid
  end

  def reminders_past(remindable)
    recurring_past_dues = []
    Reminder.where(remindable: remindable).where.not(repeats: nil).or(Reminder.where(assignee: remindable).where.not(repeats: nil)).each do |task|
      task.detect_past_dues.each do |d|
        recurring_past_dues.push(RecurringReminder.new(task, "#{task.id}_#{d[1]}", d[0]))
      end
    end

    (remindable
      .reminders.where(repeats: nil)
      .where('end_date < ?',
             Time.zone.today.in_time_zone(remindable.time_zone)).where(done_at: nil)
      .order(remind_at: :asc, id: :asc) + recurring_past_dues).sort_by(&:end_date)
  end

  def reminders_today(remindable, calendar_grid)
    today_tasks = []
    calendar_grid.each do |k, v|
      today_tasks = v if k == Time.zone.today.in_time_zone(remindable.time_zone).to_date
    end
    today_tasks.delete_if { |x| x.class.name == 'RemindersFetcher::FakeTask' }
  end

  def reminders_week(remindable, calendar_grid)
    week_tasks = []
    beginning_of_week = Time.zone.today.in_time_zone(remindable.time_zone).beginning_of_week.to_date
    calendar_grid.each do |k, v|
      week_tasks += v if k >= beginning_of_week && k <= beginning_of_week + 6.days
    end
    week_tasks.uniq.delete_if { |x| x.class.name == 'RemindersFetcher::FakeTask' }
  end
end
