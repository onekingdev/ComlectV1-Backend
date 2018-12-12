# frozen_string_literal: true

class Business::SubscriptionSettingsController < ApplicationController
  before_action :require_business!
  before_action :set_biz_sub

  def index; end

  def update
    render :index
  end

  private

  def set_biz_sub
    @business = current_business
    @forum_sub = current_business.forum_subscription
  end
end
