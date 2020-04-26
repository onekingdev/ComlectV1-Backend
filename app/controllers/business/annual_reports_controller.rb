# frozen_string_literal: true

class Business::AnnualReportsController < ApplicationController
  before_action :require_business!
  before_action :set_mock_audit_template, only: ['new']

  # rubocop:disable Style/GuardClause
  def new
    current_business.update(review_declined: true) if params[:diy].present?
    @business = current_business
    if @business.review_declined || @business.mock_audit_hired?
      if current_business.annual_reports.any?
        if current_business.annual_reports.last.pdf.nil?
          @annual_report = current_business.annual_reports.last
        else
          build_annual_report
        end
      else
        build_annual_report
      end
    end
  end
  # rubocop:enable Style/GuardClause

  def show; end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def create
    @annual_report = current_business.annual_reports.last
    @business = current_business
    respond_to do |format|
      format.jpg do
        @kit = IMGKit.new(render_to_string)
        send_data(@kit.to_jpg, type: 'image/jpeg', disposition: 'inline')
      end
      format.pdf do
        pdf = render_to_string pdf: 'annual_report.pdf',
                               template: 'business/annual_reports/annual_report.pdf.erb', encoding: 'UTF-8',
                               locals: { annual_report: @annual_report, business: current_business },
                               margin: { top:               20,
                                         bottom:            25,
                                         left:              15,
                                         right:             15 }
        uploader = PdfUploader.new(:store)
        file = Tempfile.new(["annual_report_#{@annual_report.id}", '.pdf'])
        file.binmode
        file.write(pdf)
        file.rewind
        uploaded_file = uploader.upload(file)
        @annual_report.update(pdf_data: uploaded_file.to_json, year: @annual_report.review_end.year)
        @annual_review = current_business.annual_reviews.where(year: @annual_report.review_end.year)
        doc_path = env_path(@annual_report.pdf_url.split('?')[0])
        @annual_review = if @annual_review.present?
                           @annual_review.first
                         else
                           AnnualReview.create(business_id: current_business.id, year: @annual_report.review_end.year)
                         end
        pdf_file = if Rails.env.production? || Rails.env.staging?
                     URI.parse(doc_path).open
                   else
                     File.open(doc_path)
                   end
        uploaded_pdf = uploader.upload(pdf_file)
        @annual_review.update(file_data: uploaded_pdf.to_json, pdf_data: uploaded_pdf.to_json, processed: true)
        file.delete
        redirect_to @annual_report.pdf_url
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def update
    @annual_report = AnnualReport.find(params[:id])
    if (@annual_report.business_id == current_business.id) && @annual_report.pdf.nil?
      @annual_report.update(annual_report_params)
      @prms = params['annual_report']['cof_bits']
      @cof_bits = @prms.keys.map(&:to_i) unless @prms.nil?
      unless @cof_bits.nil?
        total = 0
        @cof_bits.each do |k|
          total += (10**k).to_s.to_i(2)
        end
        @annual_report.update(cof_bits: total)
      end
    end
    redirect_to new_business_annual_report_path
  end

  private

  def build_annual_report
    @annual_report = AnnualReport.create(business_id: current_business.id)
    @annual_report.annual_review_employees.build
    @annual_report.business_changes.build
    @annual_report.regulatory_changes.build
    @annual_report.findings.build
    @annual_report.exam_start = Time.zone.today
    @annual_report.save
  end

  def annual_report_params
    # rubocop:disable Metrics/LineLength
    params.require(:annual_report).permit(:review_start, :review_end, :tailored_lvl, :cof_bits, :comments, annual_review_employees_attributes: %i[id name title department _destroy], business_changes_attributes: %i[id change _destroy], regulatory_changes_attributes: %i[id change response _destroy], findings_attributes: %i[id finding action risk_lvl _destroy compliance_category])
    # rubocop:enable Metrics/LineLength
  end

  def set_mock_audit_template
    @mock_audit = if current_business.funds?
                    current_business.total_assets > 500_000_000 ? 'mock_audit_aum_funds' : 'mock_audit_funds'
                  else
                    current_business.total_assets > 500_000_000 ? 'mock_audit_aum' : 'mock_audit'
                  end
  end

  def env_path(in_path)
    Rails.env.production? || Rails.env.staging? ? in_path : "#{Rails.root}/public#{in_path}"
  end
end
