# frozen_string_literal: true

class Reminder < ActiveRecord::Base
  belongs_to :remindable, polymorphic: true

  REPEATS = %w[Daily Weekly Monthly Yearly].freeze
  ONTYPES = %w[Day First Second Third Fourth].freeze

  serialize :skip_occurencies
  serialize :done_occurencies

  before_validation :fix_recurring_schedule

  def start_time
    remind_at
  end

  def rly_past_due
    end_date < Time.zone.today.in_time_zone(remindable.time_zone).to_date
  end

  def self.week_grid(date)
    date
  end

  def duration
    end_date.mjd - remind_at.mjd + 1
  end

  def self.find_month_day(start_date, on_type, weekday)
    occurence = ONTYPES.index(on_type)
    occurence_i = 1
    weekday = 0 if weekday == 7
    target_date = nil
    (start_date..(start_date + 1.month - 1.day)).each do |date|
      if date.wday == weekday
        if occurence > occurence_i
          occurence_i += 1
        else
          target_date = date
          break
        end
      end
    end
    target_date
  end

  def fix_recurring_schedule
    case repeats
    when 'Daily'
      self.on_type = nil
      self.repeat_on = nil
    when 'Weekly'
      sunday_fix = remind_at.wday
      sunday_fix = 7 if sunday_fix.zero?
      self.remind_at = remind_at - (sunday_fix - repeat_on).days
      self.end_date = remind_at + (duration - 1).days
      self.on_type = nil
    end
  end

  def detect_past_dues
    occurence_idx = 0
    date_cursor = remind_at
    past_dues = []
    while date_cursor < Time.zone.today.in_time_zone(remindable.time_zone).to_date
      unless skip_occurencies.include?(occurence_idx) || done_occurencies.include?(occurence_idx)
        past_dues.push(
          [date_cursor,
           occurence_idx]
        )
      end
      occurence_idx += 1
      case repeats
      when 'Daily'
        date_cursor += repeat_every.day
      when 'Weekly'
        date_cursor += (repeat_every * 7).day
      when 'Monthly'
        date_cursor = if on_type == 'Day'
                        date_cursor.change(day: repeat_on)
                      else
                        Reminder.find_month_day(date_cursor, on_type, repeat_on)
                      end
        date_cursor += repeat_every.months
        date_cursor = date_cursor.beginning_of_month
      when 'Yearly'
        date_cursor += 1.year
        date_cursor = date_cursor.change(month: repeat_every)
        date_cursor = date_cursor.beginning_of_month
        date_cursor = if on_type == 'Day'
                        date_cursor.change(day: repeat_on)
                      else
                        Reminder.find_month_day(date_cursor, on_type, repeat_on)
                      end
      end
    end
    past_dues
  end
end
