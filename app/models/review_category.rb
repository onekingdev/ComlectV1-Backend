# frozen_string_literal: true

class ReviewCategory < ApplicationRecord
  belongs_to :annual_report
  has_many :reminders, as: :linkable

  delegate :business, to: :annual_report
end
