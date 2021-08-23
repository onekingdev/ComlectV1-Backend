# frozen_string_literal: true

class ReminderSerializer < ApplicationSerializer
  attributes :id,
             :body,
             :remindable_id,
             :remind_at,
             :created_at,
             :updated_at,
             :duration,
             :done_at,
             :end_date,
             :remindable_type,
             :repeats,
             :end_by,
             :repeat_every,
             :repeat_on,
             :on_type,
             :description,
             :linkable_id,
             :linkable_type,
             :linkable_name,
             :done_occurencies,
             :note

  def linkable_name
    object.linkable.name if object.linkable.present?
  end
end
