# frozen_string_literal: true

class Business::AnnualReviewsController < ApplicationController
  before_action :set_review, only: %i[update edit show]
  before_action :require_business!

  def index
    avail_prices = [[1500, 2000, 2500], [2000, 2500, 3000]]
    @prices = current_business.employees_cnt > 10 ? avail_prices[1] : avail_prices[0]
    @business = current_business
  end

  def new
    @annual_review = AnnualReview.new
  end

  def create
    @annual_review = AnnualReview.new(annual_review_params)
    @annual_review.business_id = current_business.id
    if @annual_review.save
      PdfReviewWorker.perform_async(@annual_review.id)
      redirect_to business_annual_review_path(@annual_review)
    else
      render 'new'
    end
  end

  def update
    if @annual_review.update(annual_review_params)
      if annual_review_params['file'].present?
        @annual_review.update(processed: false)
        PdfReviewWorker.perform_async(@annual_review.id)
      end
      redirect_to business_annual_review_path(@annual_review)
    else
      render 'new'
    end
  end

  def edit
    render 'new'
  end

  def show
    if current_business == @annual_review.business
      @business = @annual_review.business
      respond_to do |format|
        format.json do
          preview_out = @annual_review.pdf && @annual_review.processed ? @annual_review.pdf_url : false
          render json: { "preview": preview_out }
        end
        format.html do
          # poof
        end
      end
    else
      redirect_to '/business'
    end
  end

  private

  def set_review
    @annual_review = current_business.annual_reviews.find(params[:id])
  end

  def annual_review_params
    params.require(:annual_review).permit(:file, :year)
  end
end
