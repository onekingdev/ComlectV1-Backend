# frozen_string_literal: true

class StripeEvent::SubscriptionUpdated < StripeEvent
  def handle
    sub = ForumSubscription.find_by(stripe_subscription_id: event.data.object.id)
    end_date = DateTime.strptime(event.data.object.current_period_end,'%s')
    sub.update(renewal_date: end_date)
    Stripe::Invoice.create(
      customer: event.data.object.customer
    )
  end
end
