# frozen_string_literal: true

class Business::ProfileController < ApplicationController
  include ActionView::Helpers::TagHelper

  before_action :require_business!

  # def show
  #   @user = current_user
  # end

  def show
    render html: content_tag('business-profile-page', '',
                             ':states': State.fetch_all_usa.to_json,
                             ':timezones': timezones_json,
                             ':contries': ISO3166::Country.all.collect(&:name).to_json,
                             ':user-id': current_user.id).html_safe, layout: 'vue_business'
  end
end
