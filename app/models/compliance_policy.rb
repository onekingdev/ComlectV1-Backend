# frozen_string_literal: true

class CompliancePolicy < ActiveRecord::Base
  acts_as_list
  belongs_to :business
  has_many :reminders, as: :linkable
  has_many :versions, -> { order(created_at: :desc) }, class_name: 'CompliancePolicy', foreign_key: :src_id
  has_and_belongs_to_many :risks
  validates :name, presence: true
  include PdfUploader[:pdf]

  scope :root, -> { where(src_id: nil) }

  def draft?
    status == 'draft'
  end

  def published?
    status == 'published'
  end
end
