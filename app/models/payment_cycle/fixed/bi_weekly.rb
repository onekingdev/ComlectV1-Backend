# frozen_string_literal: true
class PaymentCycle::Fixed::BiWeekly < PaymentCycle::Fixed
  private

  # rubocop:disable Lint/UnusedMethodArgument
  def amount_for(date, remaining_dates: nil)
    amount_for_day_period date
  end
  # rubocop:enable Lint/UnusedMethodArgument

  def occurrences
    return @_occurrences if @_occurrences
    # Skip first occurrence since it will be at the project's start date
    normal = schedule.occurrences_between(project.starts_on, project.ends_on)[1..-1]
    # Add project end date in case project ends in-between periods
    @_occurrences = (normal + [adjusted_ends_on.in_time_zone(project.business.tz)]).uniq
  end

  def schedule
    IceCube::Schedule.new(project.starts_on.in_time_zone(project.business.tz)).tap do |schedule|
      schedule.add_recurrence_rule IceCube::Rule.weekly(2)
    end
  end
end
