# frozen_string_literal: true
class Project < ActiveRecord::Base
  self.inheritance_column = '_none'

  belongs_to :business
  belongs_to :specialist
  has_one :user, through: :business
  has_and_belongs_to_many :industries
  has_and_belongs_to_many :jurisdictions
  has_and_belongs_to_many :skills
  has_many :issues, dependent: :delete_all, class_name: 'ProjectIssue'
  has_many :messages, as: :thread
  has_many :job_applications, dependent: :destroy
  has_many :timesheets, dependent: :destroy
  has_one :invite, class_name: 'ProjectInvite', dependent: :destroy
  has_many :end_requests, class_name: 'ProjectEnd', dependent: :destroy
  has_one :end_request, -> { pending }, class_name: 'ProjectEnd'
  has_many :ratings, dependent: :destroy
  has_many :charges, dependent: :destroy

  scope :visible, -> { joins(business: :user).where(users: { deleted: false }) }
  scope :recent, -> { order(created_at: :desc) }
  scope :draft_and_in_review, -> { where(status: %w(draft review)) }
  scope :published, -> { where(status: statuses[:published]) }
  scope :pending, -> { published.where(specialist_id: nil) }
  scope :active, -> { published.where.not(specialist_id: nil) }
  scope :complete, -> { where(status: statuses[:complete]) }
  scope :accessible_by, -> (user) {
    # Accessible by project owner, hired specialist, or everyone if it's published
    joins(:business).joins('LEFT OUTER JOIN specialists ON specialists.id = projects.specialist_id')
                    .where('businesses.user_id = :user_id OR projects.specialist_id = :user_id OR status = :status',
                           status: 'published', user_id: user.id)
  }

  scope :one_off, -> { where(type: 'one_off') }
  scope :full_time, -> { where(type: 'full_time') }

  scope :onsite, -> { where(location_type: 'onsite') }
  scope :remote, -> { where(location_type: 'remote') }
  scope :remote_and_travel, -> { where(location_type: 'remote_and_travel') }

  scope :with_skills, -> (names) { joins(:skills).where(skills: { name: Array(names) }) }

  scope :preload_associations, -> {
    preload(:business, :jurisdictions, :industries, :end_request)
  }

  scope :distance_between, -> (lat, lng, min, max) do
    min_m = min.to_i * 1600
    max_m = max.to_i * 1600
    distance = "ST_Distance(point, ST_GeogFromText('SRID=4326;POINT(#{lng.to_f} #{lat.to_f})'))"
    where("#{distance} >= ? AND #{distance} <= ?", min_m, max_m)
  end

  scope :pending_business_rating, -> {
    complete
      .joins("LEFT JOIN ratings ON ratings.project_id = projects.id AND ratings.rater_type = '#{Business.name}'")
      .where(ratings: { id: nil })
  }

  scope :pending_specialist_rating, -> {
    complete
      .joins("LEFT JOIN ratings ON ratings.project_id = projects.id AND ratings.rater_type = '#{Specialist.name}'")
      .where(ratings: { id: nil })
  }

  include Project::PgSearchConfig

  enum status: { draft: 'draft', review: 'review', published: 'published', complete: 'complete' }
  enum type: { one_off: 'one_off', full_time: 'full_time' }
  enum location_type: { remote: 'remote', remote_and_travel: 'remote_and_travel', onsite: 'onsite' }
  enum fee_type: { upfront_fee: 'upfront', monthly_fee: 'monthly' }

  LOCATIONS = [%w(Remote remote), %w(Remote\ +\ Travel remote_and_travel), %w(Onsite onsite)].freeze
  HOURLY_PAYMENT_SCHEDULES = [%w(Upon\ Completion upon_completion), %w(Bi-Weekly bi_weekly), %w(Monthly monthly)].freeze
  FIXED_PAYMENT_SCHEDULES = [
    %w(50/50 fifty_fifty),
    %w(Upon\ Completion upon_completion),
    %w(Bi-Weekly bi_weekly),
    %w(Monthly monthly)
  ].freeze
  PAYMENT_SCHEDULES = (HOURLY_PAYMENT_SCHEDULES + FIXED_PAYMENT_SCHEDULES).uniq.freeze
  MINIMUM_EXPERIENCE = [%w(3-7\ yrs 3-7), %w(7-10\ yrs 7-10), %w(11-15\ yrs 11-15), %w(15+\ yrs 15+)].freeze

  def self.cards_for_user(user, filter:, page:, per:)
    user.business.projects.recent
        .includes(:industries, :jurisdictions, :skills)
        .public_send(filter)
        .page(page).per(per || 6)
  end

  def requires_business_rating?
    complete? && ratings.by(business).empty?
  end

  def requires_specialist_rating?
    complete? && ratings.by(specialist).empty?
  end

  def end_requested?
    end_request.present?
  end

  def to_s
    title
  end

  def application(specialist)
    job_applications.where(specialist_id: specialist.id)
  end

  def applied?(specialist)
    application(specialist).exists?
  end

  def skill_names
    @skill_names.nil? ? skills.map(&:name) : @skill_names
  end

  def skill_names=(names)
    self.skills = names.map do |name|
      Skill.find_or_initialize_by(name: name)
    end
  end

  def pending?
    specialist_id.nil?
  end

  def active?
    published? && specialist_id.present?
  end

  def draft_or_review?
    status == self.class.statuses[:draft] || status == self.class.statuses[:review]
  end

  def location_required?
    onsite? || remote_and_travel? || full_time?
  end

  def hourly_pricing?
    one_off? && pricing_type == 'hourly'
  end

  def fixed_pricing?
    one_off? && pricing_type == 'fixed'
  end
end
