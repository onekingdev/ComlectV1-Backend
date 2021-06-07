# frozen_string_literal: true

class Api::Specialist::FavoritesController < ApiController
  before_action :require_specialist!
  skip_before_action :verify_authenticity_token

  def index
    respond_with current_specialist.favorited_projects.where(specialist_id: nil),
                 each_serializer: ProjectSerializer
  end

  def update
    project = Project.find_by id: favorite_params[:favorited_id]
    if project && favorite_params[:favorited_type] == 'Project'
      result = Favorite.toggle!(current_specialist, favorite_params)
      respond_with project_id: favorite_params[:favorited_id], favorited: result, status: :ok
    else
      respond_with status: :unprocessable_entity
    end
  end

  private

  def favorite_params
    params.require(:favorite).permit(:favorited_type, :favorited_id)
  end
end
