# frozen_string_literal: true

class ProjectRatingsController < ApplicationController
  prepend_before_action :authenticate_user!
  # skip_before_action :check_unrated_project
  before_action :find_project, :set_form_url
  before_action :set_rating_solicitation, only: :new
  protect_from_forgery only: []
  include NotificationsHelper

  def new
    @rating = @project.ratings.new(rater: specialist_or_business)
    @redirect_url = redirect_url
  end

  def create
    @rating = @project.ratings.new(rating_params.merge(rater: specialist_or_business))

    if @rating.save
      Notification::Deliver.got_rated! @rating
      js_redirect redirect_url, status: :created
    else
      render :new
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:value, :review)
  end

  def set_rating_solicitation
    if current_business
      @project.update(solicited_business_rating: true)
    elsif current_specialist
      @project.update(solicited_specialist_rating: true)
    end
  end
end
