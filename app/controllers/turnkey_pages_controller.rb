# frozen_string_literal: true

class TurnkeyPagesController < ApplicationController
  def index
    @categories = TurnkeyPage.all.order(:id)
  end

  def show
    @states = State.fetch_all_usa

    @bds = Project.all_bds

    @turnkey_page = TurnkeyPage.find_by(url: params[:id])
  end

  def create
    @solution = TurnkeySolution.find(params[:solution][:id])
    @missing = @solution.validate_params(params[:solution])
    render layout: false
  end

  def update
    if current_business && current_user.payment_info?
      @project = project_from_params(params[:solution])
      @project.save! if params.include? :solution
    end
    render layout: false
  end

  def new
    @project = Project::Form.copy(project_from_params(params[:solution]))
    render 'business/projects/new'
  end

  private

  def project_from_params(params_solution)
    solution = TurnkeySolution.find(params_solution[:id])
    if solution.validate_params(params_solution)
      template = if solution.flavored? && params_solution.include?(:flavor)
                   solution.project_templates.where(flavor: params_solution[:flavor]).first
                 else
                   solution.project_templates.first
                 end
      Project.new.build_from_template(current_business.id, template, params_solution)
    else
      Project.new
    end
  end
end
