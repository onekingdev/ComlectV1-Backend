# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::PaymentSettingsController, type: :controller do
  before(:each) do
    request.headers['Authorization'] = get_business_token
  end

  describe 'POST apply_coupon' do
    context 'with empty params' do
      let(:msg) { 'Entered Coupon code is not valid.' }
      before { post :apply_coupon, as: 'json', params: {} }

      it { expect(response).to have_http_status(422) }
      it { expect(JSON.parse(response.body)['errors']['message']).to eq(msg) }
    end

    context 'with valid coupon code' do
      let(:percent_off) { 50.0 }
      let(:coupon_id) { 'coupon_id' }
      let(:coupon_code) { 'coupon_code' }
      let(:msg) { 'Coupon code applied successfully.' }

      let(:list_object) do
        Stripe::ListObject.construct_from(
          data: [{
            code: coupon_code,
            coupon: { id: coupon_id, percent_off: percent_off, amount_off: nil }
          }]
        )
      end

      before do
        expect(Stripe::PromotionCode).to receive(:list).with(limit: 100) { list_object }
        post :apply_coupon, as: 'json', params: { coupon: coupon_code }
      end

      it { expect(response).to have_http_status(200) }
      it { expect(JSON.parse(response.body)['coupon_id']).to eq(coupon_id) }
      it { expect(JSON.parse(response.body)['percent_off']).to eq(percent_off) }
      it { expect(JSON.parse(response.body)['message']).to eq(msg) }
    end

    context 'with invalid coupon code' do
      let(:msg) { 'Entered Coupon code is not valid.' }
      let(:list_object) { Stripe::ListObject.empty_list }

      before do
        expect(list_object).to receive(:has_more) { false }
        expect(Stripe::PromotionCode).to receive(:list).with(limit: 100) { list_object }
        post :apply_coupon, params: { coupon: 'coupon_code' }
      end

      it { expect(response).to have_http_status(422) }
      it { expect(JSON.parse(response.body)['errors']['message']).to eq(msg) }
    end
  end
end
