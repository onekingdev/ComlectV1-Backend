# frozen_string_literal: true

require 'rails_helper'

describe WorkExperience do
  describe 'from to validation' do
    context 'when from is greater than to' do
      it 'is not valid' do
        experience = WorkExperience.new(from: Time.zone.today, to: Time.zone.yesterday)
        expect(experience).not_to be_valid
        expect(experience.errors[:from]).to be_present
      end
    end

    context 'when from is nil and to is truthy' do
      it 'is not valid' do
        experience = WorkExperience.new(from: nil, to: Time.zone.today)
        expect(experience).not_to be_valid
        expect(experience.errors[:from]).to be_present
      end
    end

    context 'when from is truthy and to/current is nil' do
      it 'is not valid' do
        experience = WorkExperience.new(from: Time.zone.yesterday, to: nil, current: false)
        expect(experience).not_to be_valid
        expect(experience.errors[:to]).to be_present
      end
    end
  end
end
