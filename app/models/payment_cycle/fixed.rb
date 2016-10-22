# frozen_string_literal: true
class PaymentCycle::Fixed < PaymentCycle
  def estimated_total
    project.fixed_budget
  end

  def create_charges!
    current_cycle = previous_cycle_date
    return if charge_exists?(current_cycle)
    # remaining_dates = occurrences.reject { |date| charge_exists?(date) }
    amount = amount_for(current_cycle)
    schedule_charge! amount: amount,
                     date: current_cycle,
                     description: ''
  end

  private

  def amount_for_day_period(date)
    return last_period_amount if last_period?(date)
    days = days_for_period(date)
    (days * amount_per_day_remaining).round(2)
  end

  def total_days
    # Range should be inclusive
    project.ends_on - project.starts_on + 1
  end

  def remaining_days
    outstanding_occurrences.map do |date|
      days_for_period date
    end.reduce(:+)
  end

  def amount_per_day_remaining
    BigDecimal.new(outstanding_amount) / remaining_days
  end

  def days_for_period(date)
    date = date.to_date
    period = periods.detect do |span|
      span.include?(date)
    end
    (period.last - period.first).to_i + 1
  end

  def last_period_amount
    # Because of rounding, use a different method to return the last amount
    previous = outstanding_occurrences[0..-2].map do |date|
      amount_for(date).round(2)
    end.reduce(:+)
    outstanding_amount - previous
  end

  def last_period?(date)
    periods.last.include?(date.to_date)
  end

  def periods
    previous = project.starts_on
    occurrences.map do |occurrence|
      date = occurrence.to_date
      (previous..date).tap do
        previous = date + 1.day
      end
    end
  end
end
