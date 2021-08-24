# frozen_string_literal: true

require 'validators/url_validator'
class Business < ApplicationRecord
  belongs_to :user

  has_and_belongs_to_many :jurisdictions, optional: true
  has_and_belongs_to_many :industries, optional: true
  has_many :exams
  has_many :risks
  has_many :forum_questions
  has_many :local_projects
  has_many :projects
  has_many :local_projects
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
  has_many :compliance_policies
  has_many :compliance_policy_risks
  has_many :compliance_policy_sections
  has_many :annual_reports
  has_one :team
  has_many :team_members, through: :team
  has_many :active_projects, -> { where(status: statuses[:published]).where.not(specialist_id: nil) }, class_name: 'Project'
  has_many :active_specialists, through: :active_projects, class_name: 'Specialist', source: :specialist
  has_many :outdated_compliance_policies, -> { where('last_uploaded < ?', Time.zone.today - 1.year) }, class_name: 'CompliancePolicy'
  has_many :uptodate_compliance_policies, -> { where('last_uploaded >= ?', Time.zone.today - 1.year) }, class_name: 'CompliancePolicy'
  has_many :missing_compliance_policies, -> { where(docs_count: 0) }, class_name: 'CompliancePolicy'
  has_many :sorted_unban_compliance_policies, -> { where(ban: false).order(:position) }, class_name: 'CompliancePolicy'
  has_many :sorted_compliance_policies, -> { order(:position) }, class_name: 'CompliancePolicy'
  has_many :seats
  has_many :subscriptions
  has_many :file_folders
  has_many :file_docs

  has_one :forum_subscription
  has_one :tos_agreement, through: :user
  has_one :cookie_agreement, through: :user

  has_one :referral, as: :referrable
  has_many :referral_tokens, as: :referrer
  has_many :reminders, as: :remindable
  has_many :audit_comments
  has_one :compliance_policy_configuration, dependent: :destroy

  has_settings do |s|
    s.key :in_app_notifications, defaults: {
      task_created: true,
      task_assigned: true,
      task_file_uploaded: true,
      task_new_comment: true,
      task_completed: true,
      task_overdue: true,
      project_new_bid: true,
      project_message: true,
      project_overdue: true,
      project_ended: true,
      project_completed: true,
      got_rated: true,
      got_message: true,
      new_forum_answers: true,
      new_forum_comments: true
    }
    s.key :email_notifications, defaults: {
      task_created: true,
      task_assigned: true,
      task_file_uploaded: true,
      task_new_comment: true,
      task_completed: true,
      task_overdue: true,
      project_new_bid: true,
      project_message: true,
      project_overdue: true,
      project_ended: true,
      project_completed: true,
      got_rated: true,
      got_message: true,
      new_forum_question: true,
      new_forum_comments: true
    }
    s.key :email_updates, defaults: {
      monthly_newsletter: true,
      promos_and_events: true
    }
  end

  serialize :sub_industries
  serialize :business_stages
  serialize :business_risks
  serialize :client_types
  serialize :already_covered
  serialize :cco

  after_create :add_as_employee

  def spawn_compliance_policies
    unless compliance_policies_spawned
      update(compliance_policies_spawned: true)
      I18n.t(:compliance_manual_sections).map(&:to_a).map(&:last).each do |section|
        compliance_policies.create(title: section)
      end
    end
  end

  def add_as_employee
    team_member = TeamMember.find_or_initialize_by(email: user.email, business_member: true)
    team_member.first_name = contact_first_name
    team_member.last_name =  contact_last_name
    team_member.business_member = true
    team_member.title = contact_job_title.presence || 'Compliance Officer'
    team_member.transaction do
      team_member.save
      assign_team(team_member)
    end
  end

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

  def compliance_manual_needs_update?
    missing_compliance_policies.count.positive? || outdated_compliance_policies.any?
  end

  def mock_audit_hired?
    projects.active.where(title: 'Mock Audit').any?
  end

  def reminders_this_year
    reminders.where('remind_at > ?', Time.now.in_time_zone(time_zone).beginning_of_year)
  end

  def annual_review_percentage
    if annual_reports.any?
      tgt_report = annual_reports.order(:id).last
      tgt_report.score
    else
      0
    end
  end

  def compliance_manual_percentage
    if compliance_policies.count.positive?
      uptodate_compliance_policies.where.not(docs_count: 0).count * 100 / compliance_policies.count
    else
      0
    end
  end

  def audit_prep_percentage
    return AuditRequest.count if AuditRequest.count.zero?

    (audit_comments.where.not(body: '').where.not(body: nil).count * 100 / AuditRequest.count).to_i
  end

  def completed_compliance_policies
    compliance_policies.where.not(section: nil).collect(&:section).uniq.map(&:to_sym)
  end

  def remaining_compliance_policies(protection)
    completed_arr = protection.nil? ? completed_compliance_policies : completed_compliance_policies - [protection]
    I18n.translate('compliance_manual_sections').except(*completed_arr)
  end

  def processed_annual_reports
    annual_reports.where.not(pdf_data: nil)
  end

  def processed_annual_reviews
    annual_reviews.where.not(pdf_data: nil)
  end

  def ria?
    industry = Industry.find_by(name: 'Investment Adviser')
    industry.nil? ? false : industries.collect(&:id).include?(industry.id)
  end

  def can_unlock_dashboard?
    return unless payment_sources.empty?

    return true unless ria?

    I18n.t(:business_products).keys.map(&:to_s).include?(business_stages)
  end

  def funds?
    sub_industries.present? ? sub_industries.map(&proc { |x| x.downcase.include?('fund') }).include?(true) : false
  end

  def ria_dashboard?
    ria? && ria_dashboard
  end

  def apply_quiz(cookies)
    industries_step = cookies[:complect_step2].split('-').map(&:to_i)
    self.sub_industries = []
    unless cookies[:complect_step21].nil?
      cookies[:complect_step21].split('-').map(&proc { |p| p.split('_').map(&:to_i) }).each do |c|
        sub_industries.push(Industry.find(c[0]).sub_industries.split("\r\n")[c[1]]) if industries_step.include? c[0]
      end
    end
    self.business_risks = cookies[:complect_step3].split('-').map(&:to_i)
    self.business_other = cookies[:complect_other] if industries.collect(&:name).include? 'Other'
    self.business_stages = cookies[:complect_step4]
  end

  def assign_team(team_member)
    team = team.presence || Team.create(business: Business.last, name: 'Misc', display: true)
    team_member.team_id = team.id
    team_member.save
  end

  alias communicable_projects projects
  alias_attribute :first_name, :contact_first_name
  alias_attribute :last_name, :contact_last_name

  default_scope -> { joins("INNER JOIN users ON users.id = businesses.user_id AND users.deleted = 'f'") }

  include ImageUploader[:logo]

  EMPLOYEE_OPTIONS = %w[<10 11-50 51-100 100+].freeze
  RISK_TOLERANCE_OPTIONS = [nil, '', 'Bare minimum', 'Best efforts', 'Best business practices', 'Gold standard'].freeze

  validates :description, length: { maximum: 750 }
  validates :website, allow_blank: true, url: true
  validates :linkedin_link, allow_blank: true, url: true
  validates :username, uniqueness: true, allow_blank: true
  validates :contact_first_name, :contact_last_name, presence: true
  validates :risk_tolerance, inclusion: { in: RISK_TOLERANCE_OPTIONS }, if: -> { account_created }

  validates :business_name, :industries, :jurisdiction_ids,
    :time_zone, :address_1, :city, :state, :zipcode,
    presence: true, if: -> { account_created }

  validate if: -> { time_zone.present? } do
    errors.add :time_zone unless ActiveSupport::TimeZone.all.collect(&:name).include?(time_zone)
  end

  # validate :tos_invalid?
  # validate :cookie_agreement_invalid?

  # validates :total_assets, presence: true
  # validates :client_account_cnt, presence: true
  # validates :employees, inclusion: { in: EMPLOYEE_OPTIONS }
  # validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :tos_agreement
  accepts_nested_attributes_for :cookie_agreement

  attr_accessor :sub_industry_ids

  delegate :suspended?, to: :user

  after_commit :generate_referral_token, on: :create

  def name
    business_name
  end

  def self.fix_aum(str)
    vocab = [%w[BN bn Billion billion Bill bill], '000000000'], \
            [%w[Million million MM mm Mill mill], '000000']
    result = str.gsub(/,/i, '').to_i.to_s
    occured = false
    vocab.each do |v|
      v[0].each do |word|
        if str.include?(word) && !occured
          result += v[1]
          occured = true
        end
      end
    end
    result.to_i
  end

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

  def state_or_sec
    if aum.nil? || (!aum.nil? && (aum < 100_000_000)) || only_pooled_investment?
      'state'
    else
      'sec'
    end
  end

  def only_pooled_investment?
    (!client_types.nil? && (client_types - ['pooled_investment']).count.zero?)
  end

  def pooled_investment?
    (!client_types.nil? && (client_types.include? 'pooled_investment'))
  end

  def employees_cnt
    employees.split('-')[0].scan(/\d/).join('').to_i
  end

  def all_employees
    assigned_team_members_ids = seats.pluck(:team_member_id).compact
    assigned_team_members = TeamMember.where(id: assigned_team_members_ids)
    employee_array = []
    assigned_team_members.each do |employee|
      user = User.find_by(email: employee.email)
      specialist = user.specialist if user.present?
      employee_array << specialist if specialist.present?
    end
    employee_array
  end

  def gap_analysis_est
    basic = 450
    deluxe = 1000
    premium = 2000
    # SMALL
    if state_or_sec == 'state'
      basic = 450
      if employees_cnt > 2
        deluxe = 1250
        premium = 2250
      else
        deluxe = 1000
        premium = 2000
      end
    end
    # MID
    if state_or_sec == 'sec'
      if !pooled_investment? && !client_account_cnt.nil? && (client_account_cnt > 500)
        if employees_cnt <= 10
          basic = 500
          deluxe = 1500
          premium = 2750
        end
        if (employees_cnt > 10) && (employees_cnt <= 50)
          basic = 1000
          deluxe = 2750
          premium = 4500
        end
      end
      if pooled_investment? && !aum.nil?
        if aum < 500_000_000
          basic = 2000
          deluxe = 4500
          premium = 7500
        end
        if aum >= 500_000_000
          basic = 3500
          deluxe = 6500
          premium = 11_500
        end
      end
      # LARGE
      if !aum.nil? && (aum >= 1_000_000_000)
        if !pooled_investment? && !client_account_cnt.nil? && (client_account_cnt > 500)
          basic = 1450
          deluxe = 4500
          premium = 8250
        end
        if pooled_investment?
          basic = 7500
          deluxe = 8500
          premium = 35_500
        end
      end
    end
    [basic, deluxe, premium]
  end

  def generate_username
    src = business_name.split(' ').map(&:capitalize).join('')
    generated = src.delete(' ').gsub(/[^0-9a-z ]/i, '')
    while Business.find_by_sql(['SELECT * from businesses WHERE username = ?', generated]).count.positive?
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

  def generate_referral_token
    GenerateReferralTokensJob.perform_later(self)
  end

  def subscription?
    if forum_subscription && !forum_subscription.suspended
      forum_subscription.read_attribute_before_type_cast(:level)
    else
      0
    end
  end

  def base_subscribed?
    subscriptions.base.present? ? (subscriptions&.base&.stripe_invoice_item_id && subscriptions&.base&.stripe_subscription_id) : false
  end

  def project_types
    project_base_option = [['RFP', Project.types[:rfp]], ['Custom', Project.types[:one_off]], ['Full Time', Project.types[:full_time]]]
    project_base_option << ['Internal', Project.types[:internal]] if subscriptions.base.present?
    project_base_option
  end

  def payment_source_type
    payment_source = payment_sources.find_by(primary: true) || payment_sources.first
    payment_source&.type == 'PaymentSource::Ach' ? :ach : :card
  end

  def generate_folders_tree(except_id)
    options = [] # [[id, name]]
    file_folders.root.each do |ff|
      next unless ff.id != except_id
      options.push([' - ' + ff.name, ff.id])
      ff.all_children_recursion.each do |cr|
        options.push([' -- ' + cr.name, cr.id])
      end
    end
    options
  end

  def create_annual_review_folder_if_none
    annual_review_folder = file_folders.where(name: 'Annual Review')
    if annual_review_folder.blank?
      FileFolder.create(business_id: id, name: 'Annual Review', locked: true)
    else
      annual_review_folder.first
    end
  end
end
