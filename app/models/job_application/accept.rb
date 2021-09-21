# frozen_string_literal: true

class JobApplication::Accept < Draper::Decorator
  decorates JobApplication
  delegate_all

  def self.call(application)
    ActiveRecord::Base.transaction do
      new(application).tap do |decorated|
        decorated.project.update_attribute(:specialist_id, decorated.specialist_id)
        decorated.project.complete! if decorated.project.full_time?
        decorated.set_start_and_end_dates if decorated.project.asap_duration?
        decorated.copy_proposal_to_project if decorated.rfp?
        decorated.schedule_rfp_fees
        decorated.schedule_one_off_fees
        decorated.schedule_full_time_fees
        decorated.send_specialist_notification
        decorated.notify_not_selected_applicants
        decorated.project.touch(:hired_at)
      end
    end
  end

  def set_start_and_end_dates
    return unless project.asap_duration?

    project.update(
      starts_on: Time.zone.today,
      ends_on: Time.zone.today + project.estimated_days.days
    )
  end

  def copy_proposal_to_project
    project.starts_on = starts_on
    project.ends_on = ends_on
    project.key_deliverables = key_deliverables
    project.payment_schedule = payment_schedule
    project.pricing_type = pricing_type
    project.fixed_budget = fixed_budget
    project.hourly_rate = hourly_rate
    project.estimated_hours = estimated_hours
    project.save
  end

  def schedule_rfp_fees
    return unless project.rfp?
    PaymentCycle.for(project).create_charges_and_reschedule!
  end

  def schedule_one_off_fees
    return unless project.one_off?
    PaymentCycle.for(project).create_charges_and_reschedule!
  end

  def schedule_full_time_fees
    return unless project.full_time?
    project.upfront_fee? ? schedule_upfront_fee : schedule_monthly_fee
  end

  def notify_not_selected_applicants
    project.job_applications.includes(:specialist).where.not(id: id).find_each do |application|
      Notification::Deliver.not_hired!(application)
    end
  end

  def send_specialist_notification
    Notification::Deliver.got_hired! self
  end

  private

  def schedule_upfront_fee
    return if project.business.fee_free

    project.charges.create!(
      amount_in_cents: 0,
      business_fee_in_cents: project.annual_salary * 15, # 15% in cents,
      date: Time.zone.today,
      process_after: Time.zone.today,
      status: Charge.statuses[:scheduled],
      running_balance_in_cents: 0,
      description: 'Full-time fee payable to Complect; Payment option: Upfront'
    )
  end

  def schedule_monthly_fee
    return if project.business.fee_free

    fee = project.annual_salary * 3 # 3%, 0.03 = 3 in cents
    total = fee * 6
    start_on = Time.zone.today
    6.times do |i|
      Charge.create!(
        project: project,
        date: start_on + i.months,
        process_after: start_on + i.months,
        amount_in_cents: 0,
        business_fee_in_cents: fee,
        running_balance_in_cents: total - (fee * (i + 1)),
        description: 'Full-time fee payable to Complect; Payment option: Monthly'
      )
    end
  end
end
