# frozen_string_literal: true

class Business::ProjectExtensionsController < ApplicationController
  before_action :require_business!
  before_action :find_project

  def create
    @request = ProjectExtension::Request.process! @project, params.require(:project_extension).require(:new_end_date)
    redirect_to business_project_dashboard_path(@project), notice: 'A project extension has been requested'
  end

  private

  def find_project
    @project = current_business.projects.preload_associations.find(params[:project_id])
  end
end
