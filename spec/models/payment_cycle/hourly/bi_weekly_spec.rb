# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PaymentCycle::Hourly::BiWeekly, type: :model do
  before(:all) do
    @specialist = create :specialist
  end

  describe 'an hourly project with bi-weekly pay' do
    before do
      @project = create :project_one_off_hourly,
                        payment_schedule: Project.payment_schedules[:bi_weekly],
                        starts_on: Date.new(2016, 1, 1),
                        ends_on: Date.new(2016, 3, 26)
      @job_application = create :job_application, project: @project, specialist: @specialist
      Timecop.freeze Date.new(2016, 1, 1)
    end

    after do
      Timecop.return
    end

    it 'creates estimated charges every other week' do
      JobApplication::Accept.(@job_application)
      PaymentCycle.for(@project).reschedule!
      expect(@project.charges.estimated.count).to eq(6)
      dates = [
        @project.business.tz.local(2016, 1, 18, 0, 1), # Not the 15th since that's a friday so we charge on monday
        @project.business.tz.local(2016, 2, 1, 0, 1),  # and so on...
        @project.business.tz.local(2016, 2, 15, 0, 1),
        @project.business.tz.local(2016, 2, 29, 0, 1),
        @project.business.tz.local(2016, 3, 14, 0, 1),
        @project.business.tz.local(2016, 3, 28, 0, 1)
      ]
      expect(@project.charges.estimated.map(&:process_after).sort).to eq(dates)
    end

    context 'in the middle of project with already paid work' do
      include TimesheetSpecHelper

      before do
        JobApplication::Accept.(@job_application)
        Timecop.freeze @project.starts_on + 1.week
        log_timesheet @project, hours: 5
        PaymentCycle.for(@project).create_charges_and_reschedule!
      end

      after do
        Timecop.return
      end

      it 'creates first real charge two weeks after start' do
        expect(@project.charges.real.count).to eq(1)
        charge = @project.charges.real.first
        expect(charge.amount).to eq(5 * @project.hourly_rate)
        expect(charge.process_after).to eq(@project.business.tz.local(2016, 1, 18, 0, 1))
      end

      it 'creates remaining estimated charges' do
        expect(@project.charges.estimated.count).to eq(5)
        PaymentCycle.for(@project).reschedule!
        # $5000 total - $500 paid = $4500, $4500 / 5 remaining payments = $900
        expect(@project.charges.estimated.map(&:amount).uniq).to eq([900])
        dates = [
          @project.business.tz.local(2016, 2, 1, 0, 1),
          @project.business.tz.local(2016, 2, 15, 0, 1),
          @project.business.tz.local(2016, 2, 29, 0, 1),
          @project.business.tz.local(2016, 3, 14, 0, 1),
          @project.business.tz.local(2016, 3, 28, 0, 1)
        ]
        expect(@project.charges.estimated.map(&:process_after).sort).to eq(dates)
      end
    end
  end
end
