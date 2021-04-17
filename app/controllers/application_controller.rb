# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :store_user_location!, if: :storable_location?
  before_action :lock_specialist, if: :current_specialist
  include ::Pundit
  include ::MixpanelHelper

  impersonates :user

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery prepend: true

  # Use lambda not symbol so render_403 uses the default message
  # as opposed to getting passed a Pundit::NotAuthorizedError object
  rescue_from ::Pundit::NotAuthorizedError, with: -> { render_403 }
  rescue_from ::ActionController::InvalidAuthenticityToken, with: -> {
    render_403('Your session expired, please refresh the page')
  }

  before_action -> {
    ::Notification.clear_by_path! current_user, request.path
  }, if: :user_signed_in?

  before_action :check_unrated_project, if: -> {
    user_signed_in? && request.get? && !request.xhr? && request.format.symbol == :html
  }

  private

  def lock_specialist
    return if current_specialist.dashboard_unlocked

    return if (params['controller'] == 'specialists/dashboard') && (params['action'] == 'locked')

    return redirect_to specialists_locked_path if params['controller'] != 'users/sessions' && params['controller'] != 'api/specialists'
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  def check_unrated_project
    if current_business
      project = current_business.projects.pending_business_rating.unsolicited_business_rating.first
      redirect_to business_project_dashboard_path(project) if project&.requires_business_rating?
    elsif current_specialist
      project = current_specialist.projects.pending_specialist_rating.unsolicited_specialist_rating.first
      redirect_to project_dashboard_path(project) if project&.requires_specialist_rating?
    end
  end

  def decorate(object)
    return object if object.is_a?(::Draper::Decorator)
    object.class::Decorator.decorate(object)
  end
  helper_method :decorate

  def current_business
    return @_current_business if @_current_business
    return unless user_signed_in?

    business = if session[:employee_business_id].present?
                 ::Business.find_by(id: session[:employee_business_id])
               else
                 current_user.business
               end
    return unless business

    define_current_business(business)
  end
  helper_method :current_business

  def define_current_business(business = nil)
    @_current_business = ::Business::Decorator.decorate(business || current_user.business)
  end

  def current_specialist
    return @_current_specialist if @_current_specialist
    return nil if !user_signed_in? || current_user.specialist.nil?
    @_current_specialist = ::Specialist::Decorator.decorate(current_user.specialist)
  end
  helper_method :current_specialist

  def current_business_or_specialist
    current_business || current_specialist
  end
  helper_method :current_business_or_specialist

  def redirect_to_param_or(default)
    redirect_to params[:redirect_to].presence || default
  end

  def js_alert(message)
    render partial: 'application/js_alert', locals: { message: message }
  end

  def js_notice(message, locals = {})
    render partial: 'application/js_notice', locals: locals.merge(message: message)
  end
  helper_method :js_notice

  def js_redirect(path, status: :ok)
    @path = path
    render 'application/js_redirect', status: status
  end

  def require_someone!
    if current_business || current_specialist
      @current_someone = current_business || current_specialist
    else
      render 'forbidden', status: :forbidden, locals: { message: 'Only registered users can access this page' }
    end
  end

  def require_business!
    return if user_signed_in? && current_business
    return authenticate_user! unless user_signed_in?

    render 'forbidden', status: :forbidden, locals: { message: 'Only business accounts can access this page' }
  end

  def require_specialist!
    return if user_signed_in? && current_specialist
    return authenticate_user! unless user_signed_in?
    render 'forbidden', status: :forbidden, locals: { message: 'Only specialist accounts can access this page' }
  end

  def employee?
    current_specialist&.employee?
  end
  helper_method :employee?

  def mirror?
    return false if true_user.nil? || current_business_or_specialist.nil?

    true_user.id != current_business_or_specialist.user&.id
  end
  helper_method :mirror?

  def seat?
    current_specialist&.seat?
  end
  helper_method :seat?

  # def redirect_to_employee
  #   return unless current_specialist
  #   return unless current_specialist.dashboard_unlocked
  #
  #   redirect_to employees_path if current_specialist&.employee?(current_business)
  # end

  def render_404
    render file: 'public/404', status: :not_found
  end

  def render_403(message = I18n.t('forbidden'))
    format = request.xhr? ? '.js' : ''

    render(
      template: "application/forbidden#{format}",
      locals: { message: message },
      status: :forbidden
    )
  end
end
