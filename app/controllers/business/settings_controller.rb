# frozen_string_literal: true

class Business::SettingsController < ApplicationController
  include ActionView::Helpers::TagHelper

  before_action :require_business!

  def show
    render html: content_tag('main-layout', '').html_safe, layout: 'vue_business_layout'
  end
end
