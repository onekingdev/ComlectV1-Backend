# frozen_string_literal: true
class Project::Form < Project
  include ApplicationForm

  validates :title, :description, presence: true
  validates :location_type, inclusion: { in: Project::LOCATIONS.map(&:second) }, allow_blank: true
  validates :location, presence: true, if: :location_required?
  validates :jurisdiction_ids, :industry_ids, presence: true

  ONE_OFF_FIELDS = %i(key_deliverables starts_on ends_on location_type payment_schedule estimated_hours).freeze
  FULL_TIME_FIELDS = %i(full_time_starts_on annual_salary).freeze

  validates(*ONE_OFF_FIELDS, presence: true, if: :one_off?)
  validates(*FULL_TIME_FIELDS, presence: true, if: :full_time?)

  validates :hourly_rate, presence: true, if: :hourly_pricing?
  validates :fixed_budget, presence: true, if: :fixed_pricing?
  validates :hourly_payment_schedule, :hourly_rate,
            presence: true, if: -> { hourly_pricing? && payment_schedule.blank? }
  validates :fixed_payment_schedule, :fixed_budget,
            presence: true, if: -> { fixed_pricing? && payment_schedule.blank? }
  validate if: -> { starts_on.present? && ends_on.present? } do
    errors.add :starts_on, :invalid if starts_on > ends_on
  end
  validate if: -> { starts_on.present? && ends_on.present? } do
    errors.add :ends_on, :invalid if ends_on < starts_on
  end
  validate if: -> { starts_on.present? && ends_on.present? && ends_on - starts_on < 14 } do
    attribute = hourly_pricing? ? :hourly_payment_schedule : :fixed_payment_schedule
    errors.add attribute, :too_little_duration if public_send(attribute) == 'monthly'
  end
  validate if: -> { starts_on.present? && ends_on.present? && ends_on - starts_on > 30 } do
    attribute = hourly_pricing? ? :hourly_payment_schedule : :fixed_payment_schedule
    errors.add attribute, :too_much_duration if public_send(attribute) == 'upon-completion'
  end
  validate unless: -> { user&.payment_info? } do
    errors.add :base, :no_payment
  end
  validates :skill_ids, length: { maximum: 10 }

  before_validation :assign_type_fields
  before_validation :assign_pricing_type_fields

  attr_accessor :full_time_starts_on
  attr_accessor :hourly_payment_schedule, :fixed_payment_schedule

  ATTRIBUTES_FOR_COPY = %w(
    annual_salary business_id description ends_on estimated_hours fee_type fixed_budget hourly_rate key_deliverables
    location location_type minimum_experience only_regulators payment_schedule pricing_type starts_on status title type
  ).freeze

  def self.copy(original, attributes = {})
    new(original.attributes.slice(*ATTRIBUTES_FOR_COPY)).tap do |copy|
      copy.attributes = attributes
      copy.industries = original.industries
      copy.jurisdictions = original.jurisdictions
      copy.skills = original.skills
    end
  end

  def full_time_starts_on
    @full_time_starts_on.present? ? Date.parse(@full_time_starts_on) : starts_on
  end

  def hourly_payment_schedule
    @hourly_payment_schedule || payment_schedule
  end

  def fixed_payment_schedule
    @fixed_payment_schedule || payment_schedule
  end

  private

  def assign_type_fields
    clear_fields = one_off? ? FULL_TIME_FIELDS : ONE_OFF_FIELDS
    clear_fields.each do |field|
      next unless self.class.column_names.include?(field.to_s)
      self[field] = nil
    end
    true
  end

  def assign_pricing_type_fields
    if full_time?
      self.fixed_budget = nil
      self.hourly_rate = nil
      self.starts_on = full_time_starts_on
    elsif hourly_pricing?
      self.fixed_budget = nil
      self.payment_schedule = hourly_payment_schedule
    else
      self.hourly_rate = nil
      self.payment_schedule = fixed_payment_schedule
    end
    true
  end
end