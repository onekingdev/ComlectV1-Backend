# frozen_string_literal: true

class Business::ProjectEndsController < ApplicationController
  prepend_before_action :authenticate_user!
  before_action :require_business!
  before_action :find_project

  def create
    @request = ProjectEnd::Request.process! @project
    redirect_to business_project_dashboard_path(@project), notice: 'Project end requested'
  end

  private

  def find_project
    @project = current_business.projects.preload_association.find(params[:project_id])
  end
end
