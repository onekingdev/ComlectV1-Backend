# frozen_string_literal: true

class ForumSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def create
    referer = URI(request.referer).path
    lvl = params[:subscription][:lvl].to_i
    billing_type = (params[:subscription][:pro] || params[:subscription][:basic]) == 'annual' ? 0 : 1
    if lvl.positive?
      if current_business&.payment_sources&.any?
        if current_business.subscription?.zero?
          ForumSubscription.create(business: current_business, level: lvl, billing_type: billing_type)
        else
          current_business.forum_subscription.upgrade(lvl, billing_type)
        end
        notice = 'Subscription Confirmed'
      else
        notice = "Please submit <a target='_blank' href='/business/settings/payment'>Payment Details</a> to proceed"
      end
    else
      notice = 'Incorrect options'
    end
    redirect_to referer, notice: notice
  end

  def upgrade
    referer = URI(request.referer).path
    sub = ForumSubscription.where(business_id: current_business.id).first
    sub.upgrade(params[:lvl].to_i, params[:billing_type].to_i)
    redirect_to referer, notice: 'Subscription confirmed'
  end

  def cancel
    referer = URI(request.referer).path
    current_business.forum_subscription.cancel
    redirect_to referer, notice: 'Subscription cancelled'
  end
end
