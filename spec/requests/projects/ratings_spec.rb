# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Projects::RatingsController', type: :request do
  include SessionsHelper

  describe 'POST /api/projects/:project_id/rating' do
    let(:business) { project.business }
    let(:specialist) { create(:specialist) }

    before do
      sign_in specialist.user
    end

    subject do
      post(
        api_project_rating_path(project),
        params: { value: 5, review: 'Nice working with him' },
        xhr: true, headers: authenticated_header(project.specialist.user)
      )
    end

    context 'when specialist has received review/rating prompt' do
      let(:project) {
        create(
          :project_one_off_hourly,
          :complete,
          specialist: specialist,
          solicited_specialist_rating: true
        )
      }

      it 'creates a rating' do
        subject
        puts response.body.inspect
        expect(response).to have_http_status(:created)
        expect(project.business.ratings_received.count).to eq(1)
      end
    end

    context 'when specialist has not received review/rating prompt' do
      let(:project) {
        create(
          :project_one_off_hourly,
          :complete,
          specialist: specialist,
          solicited_specialist_rating: false
        )
      }

      it 'creates a rating' do
        subject
        expect(response).to have_http_status(:created)
        expect(project.business.ratings_received.count).to eq(1)
      end

      context 'business wants notification' do
        before do
          business.settings(:email_notifications).update! got_rated: true
        end

        it 'sends notification to business' do
          expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end

      context 'business does not want notification' do
        before do
          business.settings(:email_notifications).update! got_rated: false
        end

        it 'does not send notification to business' do
          expect { subject }.to_not change { ActionMailer::Base.deliveries.count }
        end
      end
    end
  end
end
