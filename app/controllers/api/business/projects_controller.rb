# frozen_string_literal: true

class Api::Business::ProjectsController < ApiController
  before_action :require_business!
  before_action :build_project, only: %i[create]
  before_action :find_project, only: %i[show update]

  skip_before_action :verify_authenticity_token # TODO: proper authentication

  def create
    if policy(@project).post? && @project.validate
      @project.post! if @project.status != 'draft'
      @project.new_project_notification
      unless @project.local_project_id
        local_project_params = @project.attributes.slice('business_id', 'title', 'description', 'starts_on', 'ends_on')
        local_project = LocalProject.create(local_project_params)
        @project.update(local_project_id: local_project.id)
      end
      respond_with @project, serializer: ProjectSerializer
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  def update
    @project = Project::Form.find(@project.id)
    if @project.update(project_params)
      @project.post! if project_params[:status] != 'draft'
      respond_with @project, serializer: ProjectSerializer
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  def show
    respond_with @project, serializer: ProjectSerializer
  end

  private

  def build_project
    @project = Project::Form.new(business: current_user.business).tap do |project|
      project.assign_attributes project_params
    end
  end

  def project_params
    params.permit(
      :local_project_id,
      :title,
      :type,
      :location_type,
      :location,
      :lat,
      :lng,
      :description,
      :key_deliverables,
      :role_details,
      :duration_type,
      :estimated_days,
      :starts_on,
      :full_time_starts_on,
      :ends_on,
      :applicant_selection,
      :pricing_type,
      :hourly_payment_schedule,
      :fixed_payment_schedule,
      :hourly_rate,
      :upper_hourly_rate,
      :fixed_budget,
      :estimated_hours,
      :minimum_experience,
      :only_regulators,
      :annual_salary,
      :fee_type,
      :invite_id,
      :est_budget,
      :status,
      :color,
      :specialist_id,
      :rfp_timing,
      jurisdiction_ids: [],
      industry_ids: [],
      skill_names: []
    )
  end

  def find_project
    @project = current_business.projects.find(params[:id])
  end
end
