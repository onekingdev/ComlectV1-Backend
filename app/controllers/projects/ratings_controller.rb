# frozen_string_literal: true
class Projects::RatingsController < ::ProjectRatingsController
  prepend_before_action :require_specialist!

  private

  def set_form_url
    @form_url = project_rating_path(@project.id) if @project
  end

  def redirect_url
    project_dashboard_path @project
  end

  def specialist_or_business
    current_specialist
  end

  def find_project
    @project = current_specialist.projects.pending_specialist_rating.find_by(id: params[:project_id])
  end
end
