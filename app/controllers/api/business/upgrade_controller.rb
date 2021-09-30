# frozen_string_literal: true

class Api::Business::UpgradeController < ApiController
  before_action :require_business!

  def subscribe
    service = BusinessServices::StripeSubscriptionService.call(
      current_business, payment_source, upgrade_params
    )

    if service.success?
      render json: {
        message: 'subscribed',
        processed: serialize_subs(service.subscriptions)
      }, status: :created
    else
      render json: {
        error: service.error,
        processed: serialize_subs(service.subscriptions)
      }, status: :unprocessable_entity
    end
  end

  private

  def payment_source
    current_business.payment_profile&.default_payment_source
  end

  def upgrade_params
    params.require(:upgrade).permit(:plan, :seats_count, :payment_source_id, :coupon_id)
  end

  def serialize_subs(subs)
    subs.map(&proc { |psub| Business::SubscriptionSerializer.new(psub).serializable_hash })
  end
end
