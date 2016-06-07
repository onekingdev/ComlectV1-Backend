# frozen_string_literal: true
class BusinessesController < ApplicationController
  def show
    @business = Business.find(params[:id])
  end

  def new
    @business = Business.for_signup
  end

  def create
    @business = Business.for_signup(business_params)
    return redirect_to business_path(@business) if @business.save
    render :new
  end

  private

  def business_params
    params.require(:business).permit(
      :contact_first_name, :contact_last_name, :contact_email, :contact_job_title, :contact_phone,
      :business_name, :industry, :employees, :description, :website, :linkedin_link,
      :address_1, :address_2, :country, :city, :state, :zipcode,
      :anonymous,
      jurisdiction_ids: [],
      user_attributes: %i(email password)
    )
  end
end
