# frozen_string_literal: true

class Business::HiresController < ApplicationController
  before_action :require_business!
  before_action :find_project

  def new
    @job_application = @project.job_applications.find(params.require(:job_application_id))

    respond_to do |format|
      format.js
    end
  end

  def create
    if @project.pending?
      @job_application = JobApplication::Accept.(@project.job_applications.find(params.require(:job_application_id)))
    end
    redirect_path = @project.full_time? ? business_dashboard_path : business_project_dashboard_path(@project)
    js_redirect redirect_path
  end

  private

  def find_project
    @project = current_business.projects.find(params[:project_id])
  end
end
