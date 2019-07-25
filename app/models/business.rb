# frozen_string_literal: true

require 'validators/url_validator'
# rubocop:disable Metrics/ClassLength

class Business < ApplicationRecord
  belongs_to :user

  belongs_to :rewards_tier
  belongs_to :rewards_tier_override, class_name: 'RewardsTier'

  has_and_belongs_to_many :jurisdictions
  has_and_belongs_to_many :industries
  has_many :forum_questions
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

  has_one :forum_subscription
  has_one :tos_agreement, through: :user
  has_one :cookie_agreement, through: :user

  has_one :referral, as: :referrable
  has_many :referral_tokens, as: :referrer

  has_settings do |s|
    s.key :notifications, defaults: {
      marketing_emails: true,
      got_rated: true,
      project_ended: true,
      got_message: true,
      new_forum_answers: true,
      new_forum_comments: true
    }
  end

  serialize :sub_industries
  serialize :business_stages
  serialize :business_risks

  STEP_THREE = [
    'startup', 'startup rescue', 'complete ongoing maintenance', 'one-off maintenance requests'
  ].freeze

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

  # rubocop:disable Metrics/AbcSize
  def apply_quiz(cookies)
    step1_c = cookies[:complect_step1].split('-').map(&:to_i)
    self.sub_industries = []
    cookies[:complect_step11].split('-').map(&proc { |p| p.split('_').map(&:to_i) }).each do |c|
      sub_industries.push(Industry.find(c[0]).sub_industries.split("\r\n")[c[1]]) if step1_c.include? c[0]
    end
    self.business_stages = []
    cookies[:complect_step3].split('-').map(&:to_i).each { |c| business_stages.push(STEP_THREE[c]) }
    self.business_risks = []
    business_risks[0] = STEP_RISKS[0][cookies[:complect_step4].to_i]
    business_risks[1] = STEP_RISKS[1][cookies[:complect_step41].to_i]
    business_risks[2] = STEP_RISKS[2][cookies[:complect_step42].to_i]
    self.business_other = cookies[:complect_other] if industries.collect(&:name).include? 'Other'
  end
  # rubocop:enable Metrics/AbcSize

  alias communicable_projects projects

  default_scope -> { joins("INNER JOIN users ON users.id = businesses.user_id AND users.deleted = 'f'") }

  include ImageUploader[:logo]

  EMPLOYEE_OPTIONS = %w[<10 11-50 51-100 100+].freeze

  validates :contact_first_name, :contact_last_name, presence: true
  validates :business_name, :industries, :employees, presence: true
  validates :country, :city, :state, :time_zone, presence: true
  validates :description, length: { maximum: 750 }
  validates :employees, inclusion: { in: EMPLOYEE_OPTIONS }
  validates :linkedin_link, allow_blank: true, url: true
  validates :website, allow_blank: true, url: true
  # validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, uniqueness: true

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :tos_agreement
  accepts_nested_attributes_for :cookie_agreement

  validate :tos_invalid?
  validate :cookie_agreement_invalid?

  delegate :suspended?, to: :user

  after_commit :sync_with_hubspot, on: %i[create update]
  after_commit :generate_referral_token, on: :create

  after_create :sync_with_mailchimp

  def self.for_signup(attributes = {}, token = nil)
    new(attributes).tap do |business|
      business.build_user.build_tos_agreement unless business.user
      business.build_cookie_agreement unless business.user
      referral_token = ReferralToken.find_by(token: token) if token
      business.build_referral(referral_token: referral_token) if referral_token
    end
  end

  def to_param
    username
  end

  def generate_username
    src = business_name.split(' ').map(&:capitalize).join('')
    generated = src.delete(' ').gsub(/[^0-9a-z ]/i, '')
    while Business.where(username: generated).count.positive?
      ext_num = generated.scan(/\d/).join('')
      generated = if !ext_num.empty?
                    "#{src}#{ext_num.to_i + 1}"
                  else
                    "#{src}1"
                  end
    end
    generated
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

  def available_projects
    projects
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

  def processed_transactions_amount
    year = Time.zone.now.in_time_zone(tz).year
    transactions.processed.by_year(year).map(&:subtotal).inject(&:+) || 0
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

  def sync_with_hubspot
    SyncHubspotContactJob.perform_later(self)
  end

  def generate_referral_token
    GenerateReferralTokensJob.perform_later(self)
  end

  def sync_with_mailchimp
    SyncBusinessUsersToMailchimpJob.perform_later(self)
    # For dev testing and triggering heroku deploy
    # SyncBusinessUsersToMailchimpJob.perform_now(self)
  end

  def subscription?
    if forum_subscription && !forum_subscription.suspended
      forum_subscription[:level]
    else
      0
    end
  end
end
# rubocop:enable Metrics/ClassLength
