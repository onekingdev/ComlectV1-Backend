# frozen_string_literal: true

class Business::OnboardingController < ApplicationController
  include ActionView::Helpers::TagHelper

  before_action :authenticate_user!
  before_action :require_business!
  before_action :go_to_dashboard, only: :subscribe
  before_action :assign_product, only: :subscribe
  before_action :render_index, only: :subscribe

  include SubscriptionHelper
  include SubscriptionCommon

  # def index
  #   render html: content_tag('business-onboarding-page', '',
  #                            ':industry-ids': Industry.all.map(&proc { |ind|
  #                                                                 { id: ind.id,
  #                                                                   name: ind.name }
  #                                                               }).to_json,
  #                            ':jurisdiction-ids': Jurisdiction.all.map(&proc { |ind|
  #                                                                         { id: ind.id,
  #                                                                           name: ind.name }
  #                                                                       }).to_json,
  #                            ':sub-industry-ids': sub_industries(false).to_json,
  #                            ':states': State.fetch_all_usa.to_json,
  #                            ':timezones': timezones_array.to_json).html_safe,
  #          layout: 'vue_onboarding'
  # end

  def index
    render html: content_tag('auth-layoyt', '').html_safe, layout: 'vue_onboarding'
  end

  def subscribe
    stripe_customer = current_business.payment_profile.stripe_customer
    return redirect_to '/business/onboarding', flash: { error: 'No customer' } unless stripe_customer

    @product = find_product

    if current_business.base_subscribed?
      mark_passed
      return redirect_to business_dashboard_path, flash: { success: 'Already subscribed' }
    end

    if need_subscription?
      plan = begin
               params[:checkout][:schedule].to_s.downcase.strip
             rescue
               nil
             end
      return redirect_to '/business/onboarding', flash: { error: 'Wrong plan' } unless Subscription.plans.key?(plan)

      db_subscription = current_business.subscriptions.base.presence || Subscription.create(
        plan: plan,
        business_id: current_business.id,
        title: 'Compliance Command Center',
        payment_source: current_business.payment_profile.default_payment_source
      )

      add_one_time_payment(db_subscription)

      if db_subscription&.stripe_subscription_id.blank?
        sub = Subscription.subscribe(
          plan,
          stripe_customer,
          { period_ends: (Time.now.utc + 1.year).to_i },
          current_business.payment_profile.default_payment_source.coupon_id
        )
        db_subscription.update(
          stripe_subscription_id: sub.id,
          billing_period_ends: sub.cancel_at
        )
      end
    end

    project = nil

    if need_product? && @product.present?
      project = create_project

      return redirect_to '/business/onboarding', flash: { error: project.errors&.full_messages&.first } unless project.save
    end

    mark_passed

    redirect_to business_dashboard_path
  rescue => e
    redirect_to business_onboarding_path, flash: { error: (e.message if e.class.name != 'NoMethodError') }
  end

  private

  def create_project
    Project.new.build_from_template(current_business.id, @product, {})
  end

  def find_product
    return unless products?

    identifier = current_business.business_stages
    return unless identifier

    ProjectTemplate.find_by(identifier: identifier)
  end

  def assign_product
    return unless params[:onboarding].present? && params[:onboarding][:business_stages].present?

    return unless products?(params[:onboarding][:business_stages])

    current_business.update(business_stages: params[:onboarding][:business_stages])
  end

  def mark_passed
    current_business.update(onboarding_passed: true)
    current_business.update(ria_dashboard: true) if need_subscription?
    BusinessMailer.welcome(Business.find(current_business.id)).deliver_later
  end

  def go_to_dashboard
    return if (current_business.ria? && need_subscription?) || current_business.payment_sources.blank?

    return if need_product? && @product.blank?

    mark_passed
    redirect_to(business_dashboard_path)
  end

  def products?(keys = nil)
    I18n.t(:business_products).stringify_keys.key?(keys || current_business.business_stages)
  end

  def render_index
    render :index if !current_business.onboarding_passed && need_subscription? && params[:checkout].blank?
  end
end
