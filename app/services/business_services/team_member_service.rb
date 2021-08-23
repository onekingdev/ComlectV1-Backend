# frozen_string_literal: true

module BusinessServices
  class TeamMemberService < ApplicationService
    attr_reader \
      :business, :params, :team_member,
      :seat, :team, :invitation

    def initialize(business, params)
      @business = business
      @params = params
      @success = true
    end

    def success?
      @success
    end

    def call
      add_team_member
      self
    end

    private

    def add_team_member
      buid_team_member

      ActiveRecord::Base.transaction do
        team_member.save
        load_seat
        seat.assign_to(team_member.id)
        create_invitation
      end

      Notification::Deliver.got_seat_assigned!(invitation, :new_employee)
    rescue
      @success = false
    end

    def create_invitation
      @invitation = Specialist::Invitation.create(
        team: team,
        email: team_member.email,
        last_name: team_member.last_name,
        first_name: team_member.first_name,
        role: Specialist::Invitation.roles[params[:role]]
      )
    end

    def buid_team_member
      @team = business.teams.first
      @team_member = team.team_members.build(params)
    end

    def load_seat
      @seat = business.seats.available.first
      add_seat_error unless seat
    end

    def add_seat_error
      @team_member.errors.add(:seat, I18n.t('api.business.team_members.no_available_seats'))
    end
  end
end
