# frozen_string_literal: true
class PaymentProfile < ActiveRecord::Base
  belongs_to :business
  has_many :payment_sources, dependent: :destroy

  before_create :create_stripe_customer
  after_destroy :delete_stripe_data

  def stripe_customer
    Stripe::Customer.retrieve(stripe_customer_id) if stripe_customer_id.present?
  end

  def update_default_source!
    source = payment_sources.find_by!(stripe_card_id: stripe_customer.default_source)
    return if source.primary?
    payment_sources.update_all primary: false
    source.update_attribute :primary, true
  end

  private

  def create_stripe_customer
    customer = Stripe::Customer.create(description: business.business_name)
    self.stripe_customer_id = customer.id
  rescue Stripe::StripeError => e
    errors.add :base, e.message
  end

  def delete_stripe_data
    Stripe::Customer.delete stripe_customer_id
  end
end
