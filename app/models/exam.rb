# frozen_string_literal: true

class Exam < ApplicationRecord
  belongs_to :business
  has_many :exam_requests
  has_many :exam_auditors, dependent: :destroy
  accepts_nested_attributes_for :exam_requests
  has_many :reminders, as: :linkable

  validates :name, :starts_on, :ends_on, presence: true
end
