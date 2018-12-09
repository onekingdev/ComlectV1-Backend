# frozen_string_literal: true

# Schema
# t.belongs_to :business, index: true
# t.integer :billing_type, default: 0
# t.integer :level, default: 0
# t.boolean :suspended, default: false
# t.datetime :expiration
# t.timestamps null: false
# t.integer :fee
# t.string :stripe_customer_id

class ForumSubscription < ActiveRecord::Base
  belongs_to :business
  has_many :subscription_charges

  enum billing_type: %i[annual monthly]
  enum level: %i[free basic pro]

  after_create :create_subscription

  def return_plan_id
    "#{Rails.env.production? ? 'production' : 'staging'}_#{level}_#{billing_type}"
  end

  def create_subscription
    self.update_attributes(:stripe_customer_id => self.business.payment_profile.stripe_customer_id)
    begin
      sub = Stripe::Subscription.create({
        customer: self.stripe_customer_id,
        items: [{plan: self.get_plan_id}],
      })
    rescue => e
      puts e
    end
  end

  def upgrade(lvl, billing_type)
    self.billing_type = billing_type == 0 ? "annual" : "monthly"
    self.pro!
    stripe_sub = Stripe::Subscription.retrieve(self.stripe_subscription_id)
    stripe_sub.items = [{
        id: stripe_sub.items.data[0].id,
        plan: self.get_plan_id,
    }]
    stripe_sub.save
  end

  def cancel
    
  end

end
