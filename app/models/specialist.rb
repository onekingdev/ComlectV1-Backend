# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class Specialist < ApplicationRecord
  belongs_to :user, autosave: true
  belongs_to :team, foreign_key: :specialist_team_id

  belongs_to :rewards_tier
  belongs_to :rewards_tier_override, class_name: 'RewardsTier'

  before_save :calculate_years_of_experience
  has_and_belongs_to_many :industries
  has_and_belongs_to_many :jurisdictions
  has_and_belongs_to_many :skills
  has_one :managed_team, class_name: 'Team', foreign_key: :manager_id
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
  has_many :communicable_projects, class_name: 'Project', through: :job_applications, source: :project
  has_many :sent_messages, as: :sender, class_name: 'Message'
  has_many :ratings_received, -> {
    where(rater_type: Business.name).order(created_at: :desc)
  }, through: :projects, source: :ratings
  has_many :forum_ratings, -> {
    where(forum_rating: true)
  }, class_name: 'Rating'
  has_one :stripe_account, dependent: :destroy
  has_many :bank_accounts, through: :stripe_account
  has_many :email_threads, dependent: :destroy
  has_many :payments, -> { for_rfp_or_one_off_projects }, through: :projects, source: :charges
  has_many :transactions, through: :projects
  has_many :active_projects, -> { where(status: statuses[:published]).where.not(specialist_id: nil) }, class_name: 'Project'
  has_many :manageable_businesses, through: :active_projects, class_name: 'Business', source: :business
  has_one :referral, as: :referrable
  has_many :referral_tokens, as: :referrer
  # rubocop:disable Metrics/LineLength
  has_many :manageable_ria_businesses, -> { joins(:industries).where('industries.id = 5') }, through: :active_projects, class_name: 'Business', source: :business
  # rubocop:enable Metrics/LineLength

  has_settings do |s|
    s.key :notifications, defaults: {
      marketing_emails: true,
      got_rated: true,
      not_hired: true,
      project_ended: true,
      got_message: true,
      new_forum_question: true,
      new_forum_comments: true
    }
  end

  serialize :sub_industries
  serialize :sub_jurisdictions
  serialize :jurisdiction_states_usa
  serialize :jurisdiction_states_canada
  serialize :specialist_risks
  serialize :project_types

  # rubocop:disable Metrics/LineLength
  PROJECT_TYPES = ['Email Reviews', 'Annual Audits', 'On-site Assistance', 'Marketing Review', 'Gap Analysis', 'Secondments', 'Outsourced CCO', 'Outsourced COO', 'Outsourced CFO', 'Outsourced FINOP', 'Regulatory Filing', 'Outsourced OSJ', 'Ad-hoc Consulting', 'Personal Securities Monitorin', 'AML/KYC', 'Cybersecurity', 'Internal Reviews', 'Independent Director'].freeze
  # rubocop:enable Metrics/LineLength

  STEP_RISKS = [
    [
      'You head over and take a piece, because it worked out for the other two mice',
      'You think about it, but end up playing it safe',
      'You would have been on that cheese the moment you saw it',
      'You need to do more research and want to see if more mice are succesful',
      'No, thank you! Risk death? Not worth it.'
    ],
    [
      'Slow down to the speed limit in case it’s a cop ',
      'Moderate your speed to the flow of traffic ',
      'You’d never speed ',
      'Hope for the best, because you can’t afford to be late to this meeting',
      'You always speed, even if cops are around, because they have to catch you first'
    ],
    [
      'To win big, you sometimes have to take big risks',
      'Measure twice, cut once',
      'My belief in a day of reckoning keeps me on the straight and narrow',
      'There’s a fine line between taking a calculated risk and doing something dumb',
      'The biggest risk is not taking any risk'
    ]
  ].freeze

  # def manageable_ria_businesses
  #  industry = Industry.find_by(name: 'Investment Adviser')
  #  arr = manageable_businesses
  #  tgt_arr = []
  #  arr.each do |b|
  #    tgt_arr.push(b) if b.industries.include? industry
  #  end
  #  arr.uniq!
  #  tgt_arr
  # end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def apply_quiz(cookies)
    step1_c = cookies[:complect_s_step1].split('-').map(&:to_i)
    self.sub_industries = []
    unless cookies[:complect_s_step21].nil?
      cookies[:complect_s_step21].split('-').map(&proc { |p| p.split('_').map(&:to_i) }).each do |c|
        sub_industries.push(Industry.find(c[0]).sub_industries_specialist.split("\r\n")[c[1]]) if step1_c.include? c[0]
      end
    end
    self.specialist_risks = cookies[:complect_s_step4].split('-').map(&:to_i)
    self.specialist_other = cookies[:complect_s_other] if industries.collect(&:name).include? 'Other'

    unless cookies[:complect_s_states_usa].nil?
      tgt_states = []
      cookies[:complect_s_states_usa].split('-').each do |usa_state|
        tgt_states.push(usa_state) if State.fetch_all_usa.include?(usa_state)
      end
      self.jurisdiction_states_usa = tgt_states
    end

    unless cookies[:complect_s_states_canada].nil?
      tgt_states = []
      cookies[:complect_s_states_canada].split('-').each do |can_state|
        tgt_states.push(can_state) if State.fetch_all_canada.include?(can_state)
      end
      self.jurisdiction_states_canada = tgt_states
    end

    # rubocop:disable Style/GuardClause
    unless cookies[:complect_s_step3].nil?
      sub_jurs = cookies[:complect_s_step3].split('-')
      if sub_jurs.include?('0_1') # Other
        self.sub_jurisdictions_other = cookies[:complect_s_jur_other] unless cookies[:complect_s_jur_other].nil?
        sub_jurs.delete('0_1')
      end
      self.sub_jurisdictions = []
      sub_jurs.map(&proc { |p| p.split('_').map(&:to_i) }).each do |c|
        sub_jurisdictions.push(Jurisdiction.find(c[0]).sub_jurisdictions_specialist.split("\r\n")[c[1]])
      end
    end
    # rubocop:enable Style/GuardClause
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  has_one :tos_agreement, through: :user
  has_one :cookie_agreement, through: :user
  accepts_nested_attributes_for :education_histories, :work_experiences
  accepts_nested_attributes_for :tos_agreement
  accepts_nested_attributes_for :cookie_agreement
  validate :tos_invalid?
  validate :cookie_agreement_invalid?
  validates :username, uniqueness: true

  default_scope -> { joins("INNER JOIN users ON users.id = specialists.user_id AND users.deleted = 'f'") }

  scope :preload_associations, -> {
    preload(
      :user,
      :work_experiences,
      :education_histories,
      :industries,
      :jurisdictions,
      :skills
    )
  }

  scope :join_experience, -> {
    joins(:work_experiences)
      .where(work_experiences: { compliance: true })
      .group(:id)
  }

  scope :experience_between, ->(min, max) {
    if max
      where('years_of_experience BETWEEN ? AND ?', min, max)
    else
      where('years_of_experience >= ?', min)
    end
  }

  scope :by_experience, ->(dir = :desc) {
    order("years_of_experience #{dir}")
  }

  scope :by_distance, ->(lat, lng) do
    order("ST_Distance(point, ST_GeogFromText('SRID=4326;POINT(#{lng.to_f} #{lat.to_f})'))")
  end

  scope :close_to, ->(lat, lng, miles) do
    meters = miles.to_i * 1600
    where("ST_DWithin(point, ST_GeogFromText('SRID=4326;POINT(#{lng.to_f} #{lat.to_f})'), #{meters})")
  end

  scope :distance_between, ->(lat, lng, min, max) do
    min_m = min.to_i * 1600
    max_m = max.to_i * 1600
    distance = "ST_Distance(point, ST_GeogFromText('SRID=4326;POINT(#{lng.to_f} #{lat.to_f})'))"
    where("#{distance} >= ? AND #{distance} <= ?", min_m, max_m)
  end

  scope :public_profiles, -> { where(visibility: Specialist.visibilities[:is_public]) }

  include ImageUploader[:photo]
  include PdfUploader[:resume]

  enum visibility: { is_public: 'public', is_private: 'private' }

  delegate :suspended?, to: :user

  after_commit :generate_referral_token, on: :create

  after_create :sync_with_mailchimp

  def to_param
    username
  end

  def generate_username
    src = "#{first_name&.capitalize}#{last_name[0]&.capitalize}"
    generated = src.gsub(/[^0-9a-z ]/i, '') # yes
    while Specialist.find_by_sql(['SELECT * from specialists WHERE username = ?', generated]).count.positive?
      ext_num = generated.scan(/\d/).join('')
      generated = if !ext_num.empty?
                    "#{src}#{ext_num.to_i + 1}"
                  else
                    "#{src}1"
                  end
    end
    generated.delete(' ')
  end

  def tos_invalid?
    errors.add(:tos_agree, 'You must agree to the terms of service to create an account') unless user.tos_agreement&.status
  end

  def cookie_agreement_invalid?
    errors.add(:cookie_agree, 'You must agree to cookies to create an account') unless user.cookie_agreement&.status
  end

  def referral_token
    referral_tokens.last
  end

  def ratings_combined
    (ratings_received.preload_associations + forum_ratings).sort_by(&:created_at).reverse
  end

  # def years_of_experience
  #  return @_years_of_experience if @_years_of_experience
  #  @_years_of_experience = (calculate_years_of_experience / 365.0).round
  # end

  def calculate_years_of_experience
    yrs = work_experiences.compliance.map do |exp|
      exp.from ? ((exp.to || Time.zone.today) - exp.from).to_f : 0.0
    end.reduce(:+) || 0.0
    self.years_of_experience = (yrs / 365.0).round
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
    full_name
  end

  def full_name
    [first_name, last_name].map(&:presence).compact.join(' ')
  end

  def manager
    team&.manager || self
  end

  def public?
    is_public?
  end

  def private?
    is_private?
  end

  def manager?
    !managed?
  end

  def managed?
    !team.nil?
  end

  def processed_transactions_amount
    year = Time.zone.now.in_time_zone(tz).year
    transactions.processed.by_year(year).map(&:specialist_total).inject(&:+) || 0
  end

  alias original_rewards_tier rewards_tier
  def rewards_tier
    return RewardsTier.default unless original_rewards_tier
    return rewards_tier_override if rewards_tier_override_precedence?
    original_rewards_tier
  end

  def rewards_tier_override_precedence?
    return false unless rewards_tier_override
    rewards_tier_override.fee_percentage < original_rewards_tier.fee_percentage
  end

  def generate_referral_token
    GenerateReferralTokensJob.perform_later(self)
  end

  def sync_with_mailchimp
    SyncSpecialistUsersToMailchimpJob.perform_later(self)
  end

  # rubocop:disable Style/GuardClause
  def calc_forum_upvotes
    if user.upvotes > forum_upvotes_for_review
      update(forum_upvotes_for_review: user.upvotes)
      if (forum_upvotes_for_review % 25).zero?
        rating = Rating.create(value: 5, review: 'Quality advice!', forum_rating: true, specialist_id: id, should_update_stats: true)
        Notification::Deliver.got_rated! rating
      end
    end
  end
  # rubocop:enable Style/GuardClause
end
# rubocop:enable Metrics/ClassLength
