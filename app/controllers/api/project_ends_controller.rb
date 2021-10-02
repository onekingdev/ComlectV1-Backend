# index show

# frozen_string_literal: true

class Api::ProjectEndsController < ApiController
  before_action :require_someone!
  before_action :find_project

  skip_before_action :verify_authenticity_token # TODO: proper authentication

  def create
    if ProjectEnd::Request.process!(@project, @current_someone)
      render json: { success: I18n.t('api.project_ends.requested'), project: @project }
    else
      render json: { error: I18n.t('api.project_ends.request_failure') }
    end
  end

  def update
    return render_404 unless @project.end_requested?
    if ProjectEnd::Request.confirm_or_deny!(@project, params.slice(:confirm, :deny), @current_someone)
      render json: { success: I18n.t('api.project_ends.confirmed') }
    else
      render json: { error: I18n.t('api.project_ends.confirm_from_other_side') }
    end
  end

  private

  def find_project
    @project = @current_someone.projects.preload_association.find(params[:project_id])
  end
end
