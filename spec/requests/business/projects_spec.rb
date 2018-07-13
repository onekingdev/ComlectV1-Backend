# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creating a project', type: :request do
  include SessionsHelper

  before(:all) do
    StripeMock.start
  end

  after(:all) do
    StripeMock.stop
  end

  let(:industry) { create(:industry) }
  let(:jurisdiction) { create(:jurisdiction) }
  let(:business) { create(:business, :with_payment_profile) }

  before do
    sign_in business.user
    subject
  end

  subject do
    post business_projects_path, project: {
      status: 'published',
      title: 'Foo',
      description: 'bar baz',
      type: 'one_off',
      duration_type: 'custom',
      starts_on: 1.month.from_now,
      ends_on: 2.months.from_now,
      location_type: 'remote',
      key_deliverables: 'Key deliverables',
      industry_ids: [industry.id],
      jurisdiction_ids: [jurisdiction.id],
      minimum_experience: Project::MINIMUM_EXPERIENCE.first.last,
      hourly_rate: '50',
      estimated_hours: '2',
      pricing_type: 'hourly',
      hourly_payment_schedule: 'upon_completion'
    }
  end

  it 'redirects to the business dashboard' do
    expect(response).to redirect_to(business_dashboard_path)
  end
end
