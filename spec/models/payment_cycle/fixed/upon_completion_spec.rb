# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentCycle::Fixed::UponCompletion, type: :model do
  before(:all) do
    StripeMock.start
    @specialist = create(:specialist)
  end

  after(:all) do
    StripeMock.stop
  end

  describe 'a fixed-budget project with upon-completion pay' do
    before do
      Timecop.freeze(Date.new(2015, 12, 25)) do
        @business = create(
          :business,
          :with_payment_profile,
          time_zone: 'Pacific Time (US & Canada)'
        )

        @project = create(
          :project_one_off_fixed,
          business: @business,
          payment_schedule: Project.payment_schedules[:upon_completion],
          fixed_budget: 10_000,
          starts_on: Date.new(2016, 1, 1),
          ends_on: Date.new(2016, 2, 1)
        )

        @job_application = create(
          :job_application,
          project: @project,
          specialist: @specialist
        )

        Project::Form.find(@project.id).post!
        JobApplication::Accept.(@job_application)
      end
    end

    it 'creates a single estimated charge at end of project' do
      Timecop.freeze(@project.starts_on + 1.day) do
        PaymentCycle.for(@project).create_charges_and_reschedule!
      end

      expect(@project.charges.estimated.count).to eq(1)
      charge = @project.charges.estimated.first
      expect(charge.amount).to eq(10_000)
      process_after = charge.process_after.in_time_zone(@project.business.tz)
      expect(process_after).to eq(@project.business.tz.local(2016, 2, 1, 0, 1))
    end

    context 'when project is ended early' do
      before do
        middle_of_project = @project.starts_on + ((@project.ends_on - @project.starts_on) / 2)
        Timecop.freeze(middle_of_project) do
          request = ProjectEnd::Request.process!(@project)
          request.confirm!
        end
      end

      it 'reschedules payment' do
        expect(@project.reload.charges.count).to eq(1)
        charge = @project.reload.charges.first
        expect(charge.amount).to eq(@project.fixed_budget)
        expect(charge.date).to eq(Date.new(2016, 1, 16))
      end
    end
  end
end
