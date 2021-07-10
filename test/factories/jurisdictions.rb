# frozen_string_literal: true

FactoryBot.define do
  factory :jurisdiction do
    sequence :name do |n|
      %w[USA Canada Africa Central\ America Asia South\ America Australasia Europe][n]
    end
  end
end
