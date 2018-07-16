# frozen_string_literal: true

class Business::ProjectMessagesController < ProjectMessagesController
  before_action :require_business!

  def index
    Notification.clear! current_user, :business_got_project_message, @project
    super
  end

  private

  def path_after_create
    business_project_dashboard_path @project
  end

  def user_project_messages_path
    if params[:specialist_id].blank?
      business_project_messages_path @project
    else
      business_project_messages_path(@project, params[:specialist_id].to_i)
    end
  end
  helper_method :user_project_messages_path

  def recipient
    @project.specialist
  end

  def sender
    current_business
  end
  helper_method :sender
end
