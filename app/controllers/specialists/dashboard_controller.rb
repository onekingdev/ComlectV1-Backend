# frozen_string_literal: true
class Specialists::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :require_specialist!

  def show
    @specialist = Specialist.preload_associations.find(current_user.specialist.id)
  end
end
