# frozen_string_literal: true

module RemindersUpdater
  def skip_occurence(reminder)
    reminder.update(skip_occurencies: reminder.skip_occurencies + [params[:oid].to_i])
  end

  def change_reminder_state
    upd_time = Time.zone.now.in_time_zone(@reminder.remindable.time_zone)
    if params[:oid].present?
      if params[:done] == 'false'
        @reminder.update(done_occurencies: @reminder.done_occurencies.tap { |hs| hs.delete(params[:oid].to_i) })
      else
        @reminder.update(done_occurencies: @reminder.done_occurencies.merge(params[:oid].to_i => [upd_time, nil]))
      end
    else
      @reminder.update(done_at: (params[:done] == 'false' ? nil : upd_time), note: nil)
    end
  end
end
