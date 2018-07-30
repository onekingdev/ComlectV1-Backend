# frozen_string_literal: true

require 'validators/url_validator'

class Business < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :jurisdictions
  has_and_belongs_to_many :industries
  has_many :projects, dependent: :destroy
  has_many :job_applications, through: :projects
  has_many :charges, through: :projects
  has_many :transactions, through: :projects
  has_one :payment_profile, dependent: :destroy
  has_many :payment_sources, through: :payment_profile
  has_many :project_invites, dependent: :destroy
  has_many :favorites, as: :owner
  has_many :favorited_by, as: :favorited, dependent: :destroy, class_name: 'Favorite'
  has_many :favorite_specialists, through: :favorites, source: :favorited, source_type: 'Specialist'
  has_many :hired_specialists, -> { distinct }, through: :projects, source: :specialist
  has_many :sent_messages, as: :sender, class_name: 'Message'
  has_many :ratings_received, -> {
    where(rater_type: Specialist.name).order(created_at: :desc)
  }, through: :projects, source: :ratings
  has_many :email_threads, dependent: :destroy

  include DiscourseUsernameGenerator

  has_settings do |s|
    s.key :notifications, defaults: {
      marketing_emails: true,
      got_rated: true,
      project_ended: true,
      got_message: true
    }
  end

  default_scope -> { joins("INNER JOIN users ON users.id = businesses.user_id AND users.deleted = 'f'") }

  include ImageUploader[:logo]

  EMPLOYEE_OPTIONS = %w[<10 11-50 51-100 100+].freeze

  validates :contact_first_name, :contact_last_name, :contact_email, presence: true
  validates :business_name, :industries, :employees, :description, presence: true
  validates :country, :city, :state, :time_zone, presence: true
  validates :description, length: { maximum: 750 }
  validates :employees, inclusion: { in: EMPLOYEE_OPTIONS }
  validates :linkedin_link, allow_blank: true, url: true
  validates :website, allow_blank: true, url: true

  accepts_nested_attributes_for :user

  enum rewards_tier: { gold: 0, platinum: 1, platinum_honors: 2 }

  delegate :suspended?, to: :user

  def self.for_signup(attributes = {})
    new(attributes).tap do |business|
      business.build_user unless business.user
    end
  end

  def in_usa?
    country == 'US'
  end

  def tz
    ActiveSupport::TimeZone[time_zone.to_s] || Time.zone
  end

  def messages
    Message.where("
      (recipient_type = '#{Business.name}' AND recipient_id = :id) OR
      (sender_type = '#{Business.name}' AND sender_id = :id)", id: id)
  end

  def to_s
    business_name
  end

  def public?
    !anonymous?
  end

  def contact_full_name
    [contact_first_name, contact_last_name].map(&:presence).compact.join(' ')
  end

  def completed_projects_amount
    projects.complete.sum(:calculated_budget)
  end
end
