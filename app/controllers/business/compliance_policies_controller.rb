# frozen_string_literal: true

class Business::CompliancePoliciesController < ApplicationController
  include ActionView::Helpers::TagHelper

  before_action :require_business!
  before_action :set_cpolicy, only: %i[update edit show destroy ban unban]

  def index
    render html: content_tag('main-layoyt', '').html_safe, layout: 'vue_business_layout'
  end

  def show
    render html: content_tag('main-layoyt', '',
                             ':policy-id': params[:id]).html_safe, layout: 'vue_builder_layout'
  end

  def entire
    render html: content_tag('main-layoyt', '').html_safe, layout: 'vue_business_layout'
  end

  private

  def set_cpolicy
    @business = current_business
    @compliance_policy = current_business.compliance_policies.find(params[:id])
  end
end
