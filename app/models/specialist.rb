# frozen_string_literal: true
class Specialist < ActiveRecord::Base
  belongs_to :user, autosave: true
  has_and_belongs_to_many :industries
  has_and_belongs_to_many :jurisdictions
  has_and_belongs_to_many :skills
  has_many :work_experiences, dependent: :destroy
  has_many :education_histories, dependent: :delete_all
  has_many :favorites, as: :owner, dependent: :destroy
  has_many :favorited_by, as: :favorited, dependent: :destroy, class_name: 'Favorite'
  has_many :favorited_projects, class_name: 'Project', through: :favorites, source: :favorited, source_type: 'Project'
  has_many :projects
  has_many :job_applications, dependent: :destroy
  has_many :applied_projects, -> {
    where(specialist_id: nil)
  }, class_name: 'Project', through: :job_applications, source: :project
  has_many :sent_messages, as: :sender, class_name: 'Message'
  has_many :ratings_received, -> {
    where(rater_type: Business.name).order(created_at: :desc)
  }, through: :projects, source: :ratings
  has_many :stripe_accounts, dependent: :destroy
  has_many :email_threads, dependent: :destroy
  has_many :payments, -> { for_one_off_projects }, through: :projects, source: :charges
  has_many :transactions, through: :projects

  include DiscourseUsernameGenerator

  has_settings do |s|
    s.key :notifications, defaults: {
      marketing_emails: true,
      got_rated: true,
      not_hired: true,
      project_extension_requested: true,
      project_end_requested: true,
      got_message: true
    }
  end

  accepts_nested_attributes_for :education_histories, :work_experiences

  default_scope -> { joins("INNER JOIN users ON users.id = specialists.user_id AND users.deleted = 'f'") }

  scope :preload_associations, -> {
    preload(:user, :work_experiences, :education_histories, :industries, :jurisdictions, :skills)
  }

  scope :join_experience, -> {
    joins(:work_experiences)
      .select("specialists.*, #{dates_between_query} AS years_of_experience")
      .group(:id)
  }

  scope :experience_between, -> (min, max) {
    base_scope = join_experience.where(work_experiences: { compliance: true })
    if max
      base_scope
        .having("#{dates_between_query} BETWEEN ? AND ?", min, max)
    else
      base_scope
        .having("#{dates_between_query} >= ?", min)
    end
  }

  scope :by_experience, -> (dir = :desc) {
    join_experience.order("years_of_experience #{dir}")
  }

  scope :by_distance, -> (lat, lng) do
    order("ST_Distance(point, ST_GeogFromText('SRID=4326;POINT(#{lng.to_f} #{lat.to_f})'))")
  end

  scope :close_to, -> (lat, lng, miles) do
    meters = miles.to_i * 1600
    where("ST_DWithin(point, ST_GeogFromText('SRID=4326;POINT(#{lng.to_f} #{lat.to_f})'), #{meters})")
  end

  scope :distance_between, -> (lat, lng, min, max) do
    min_m = min.to_i * 1600
    max_m = max.to_i * 1600
    distance = "ST_Distance(point, ST_GeogFromText('SRID=4326;POINT(#{lng.to_f} #{lat.to_f})'))"
    where("#{distance} >= ? AND #{distance} <= ?", min_m, max_m)
  end

  scope :public_profiles, -> { where(visibility: Specialist.visibilities[:is_public]) }

  include ImageUploader[:photo]
  include PdfUploader[:resume]

  enum visibility:  { is_public: 'public', is_private: 'private' }

  delegate :suspended?, to: :user

  def self.dates_between_query
    'SUM(ROUND((COALESCE("to", NOW())::date - "from"::date)::float / 365.0)::numeric::int)'
  end
  private_class_method :dates_between_query

  def stripe_account
    stripe_accounts.primary.first
  end

  def messages
    Message.where("
      (recipient_type = '#{Specialist.name}' AND recipient_id = :id) OR
      (sender_type = '#{Specialist.name}' AND sender_id = :id)", id: id)
  end

  def messaged_parties
    Business
      .distinct
      .joins("
        INNER JOIN messages ON
          (messages.recipient_type = '#{Business.name}' AND messages.recipient_id = businesses.id) OR
          (messages.sender_type = '#{Business.name}' AND messages.sender_id = businesses.id)
      ")
      .where("
        (messages.recipient_type = '#{Specialist.name}' AND messages.recipient_id = :id) OR
        (messages.sender_type = '#{Specialist.name}' AND messages.sender_id = :id)
      ", id: id)
  end

  def tz
    ActiveSupport::TimeZone[time_zone.to_s] || Time.zone
  end

  def to_s
    first_name
  end

  def full_name
    [first_name, last_name].map(&:presence).compact.join(' ')
  end

  def public?
    is_public?
  end

  def private?
    is_private?
  end
end
