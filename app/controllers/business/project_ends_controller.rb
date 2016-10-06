# frozen_string_literal: true
class Business::ProjectEndsController < ApplicationController
  before_action :require_business!
  before_action :find_project

  def create
    @request = ProjectEnd::Request.process! @project
    js_notice 'Project end requested', title: false
  end

  private

  def find_project
    @project = current_business.projects.preload_associations.find(params[:project_id])
  end
end
