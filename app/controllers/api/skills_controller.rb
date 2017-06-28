# frozen_string_literal: true

class Api::SkillsController < ApiController
  def index
    @skills = skill_search(params[:q])
    respond_to do |format|
      format.json
    end
  end

  private

  def skill_search(query)
    return Skill.all if query.blank?
    Skill.where('name ILIKE ?', "%#{params[:q]}%")
  end
end
