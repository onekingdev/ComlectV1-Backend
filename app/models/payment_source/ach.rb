# frozen_string_literal: true
class PaymentSource::ACH < PaymentSource
  attr_accessor :validate1, :validate2

  class << self
    private

    def add_to_existing(profile, params)
      source = profile.payment_sources.new params.merge(primary: profile.payment_sources.empty?)
      source.save if profile.errors.empty?
      source
    rescue Stripe::StripeError => e
      errors.add :base, e.message
      source
    end

    def create_profile_and_add(business, params)
      profile = business.create_payment_profile
      add_to_existing profile, params
    end
  end

  def validate_microdeposits(params)
    account = stripe_customer.sources.retrieve(stripe_id)
    account.verify amounts: [params[:validate1].to_i, params[:validate2].to_i]
    update_attribute :validated, true
  rescue Stripe::CardError => _e
    errors.add :base, "Amounts don't match"
  end

  def create_source
    stripe_customer.sources.create(source: token)
    true
  rescue Stripe::StripeError => e
    errors.add :base, e.message
    false
  end

  def bank_account?
    true
  end
end
