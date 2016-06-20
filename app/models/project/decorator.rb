# frozen_string_literal: true
class Project::Decorator < Draper::Decorator
  decorates Project
  decorates_association :business, with: Business::Decorator
  delegate_all

  def confirm_delete
    "Are you sure you want to delete this project?<h2>#{title}</h2>
     This can't be undone and this project will no longer appear in your dashboard, even as a draft.".html_safe
  end

  def location_details
    return location if full_time?
    [location_type_humanized, location.presence].compact.join(', ')
  end

  def dollars
    amount = if full_time?
               annual_salary
             else
               hourly_pricing? ? hourly_rate : fixed_budget
             end
    h.number_to_currency(amount, precision: 0) + ('/hr' if hourly_rate?).to_s
  end

  def start_and_duration
    string = I18n.l(starts_on, format: :short_ord).gsub('%@d', starts_on.day.ordinalize)
    return string if full_time?
    "#{string}, #{duration}"
  end

  def duration
    starts_on.distance_in_words_from(ends_on)
  end

  def type_humanized
    { 'one_off' => 'One-time Project', 'full_time' => 'Full-time Role' }[type]
  end

  def minimum_experience_humanized
    return 'None' if minimum_experience.blank?
    "#{minimum_experience} Years"
  end

  def location_type_humanized
    Project::LOCATIONS.find { |_key, value| value == location_type }.first
  end

  def payment_schedule_humanized
    Project::PAYMENT_SCHEDULES.find { |_key, value| value == payment_schedule }.first
  end

  def hourly_rate_input(builder)
    builder.input :hourly_rate,
                  required: true,
                  wrapper: :vertical_form,
                  input_html: { class: 'input-lg' }
  end

  def fixed_budget_input(builder)
    builder.input :fixed_budget,
                  required: true,
                  wrapper: :vertical_form,
                  input_html: { class: 'input-lg' }
  end

  def hourly_payment_schedule_input(builder)
    builder.input :hourly_payment_schedule,
                  collection: Project::HOURLY_PAYMENT_SCHEDULES,
                  include_blank: false,
                  required: true,
                  wrapper: :vertical_form,
                  input_html: { class: 'input-lg js-select' }
  end

  def fixed_payment_schedule_input(builder)
    builder.input :fixed_payment_schedule,
                  collection: Project::FIXED_PAYMENT_SCHEDULES,
                  include_blank: false,
                  required: true,
                  wrapper: :vertical_form,
                  input_html: { class: 'input-lg js-select' }
  end

  def industries_input(builder)
    builder.input :industry_ids,
                  as: :grouped_select,
                  collection: grouped_collection_for_select(Industry.all),
                  group_method: :all,
                  group_label_method: :label,
                  placeholder: I18n.t('simple_form.placeholders.project.industries'),
                  input_html: { class: 'input-lg js-select', multiple: true }
  end

  def jurisdictions_input(builder)
    builder.input :jurisdiction_ids,
                  as: :grouped_select,
                  collection: grouped_collection_for_select(Jurisdiction.all),
                  group_method: :all,
                  group_label_method: :label,
                  placeholder: I18n.t('simple_form.placeholders.project.jurisdictions'),
                  input_html: { class: 'input-lg js-select', multiple: true }
  end

  def skills_input(builder)
    # Selected options should appear at the top
    skills = Skill.all.sort_by { |skill| skill_ids.include?(skill.id) ? 0 : 1 }
    builder.input :skill_ids,
                  collection: skills,
                  placeholder: I18n.t('simple_form.placeholders.project.skills'),
                  input_html: { class: 'input-lg js-select', multiple: true }
  end

  def grouped_collection_for_select(array)
    [array].map do |collection|
      collection.define_singleton_method :all do
        collection
      end
      def collection.label
        'Select all'
      end
      collection
    end
  end
end
