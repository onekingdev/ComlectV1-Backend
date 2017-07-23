# frozen_string_literal: true

class PaymentCycle::Fixed::Monthly < PaymentCycle::Fixed
  private

  def charge_description
    'Monthly project payment'
  end

  # rubocop:disable Lint/UnusedMethodArgument
  def amount_for(date, remaining_dates: nil)
    amount_for_day_period date
  end
  # rubocop:enable Lint/UnusedMethodArgument

  def occurrences
    # Skip first occurrence since it will be at the project's start date
    normal = schedule.occurrences_between(
      project.starts_on.in_time_zone(timezone),
      project.ends_on.in_time_zone(timezone)
    )[1..-1]

    # Add project end date in case project ends in-between periods
    (normal + [project.ends_on.in_time_zone(timezone)]).uniq
  end

  def schedule
    IceCube::Schedule.new(project.starts_on.in_time_zone(timezone)).tap do |schedule|
      schedule.add_recurrence_rule IceCube::Rule.monthly
    end
  end
end
