# frozen_string_literal: true

class Api::Business::TeamMembersController < ApiController
  before_action :require_business!

  def create
    service = BusinessServices::TeamMemberService.call(current_business, member_params)

    if service.success?
      respond_with service.team_member, serializer: ::TeamMemberSerializer
    else
      respond_with service.team_member
    end
  end

  private

  def member_params
    params.require(:team_member).permit(
      :first_name, :last_name, :email,
      :role, :start_date, :access_person
    )
  end
end
