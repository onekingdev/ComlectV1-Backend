# frozen_string_literal: true

FactoryBot.define do
  factory :specialist do
    association :user, email_prefix: 'specialist'
    association :rewards_tier
    industries { [create(:industry)] }
    jurisdictions { [create(:jurisdiction)] }
    work_experiences { [create(:work_experience)] }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    time_zone { Faker::Address.time_zone }
    address_1 { Faker::Address.street_address }
    country { Faker::Address.country }

    trait :credit do
      credits_in_cents 6000
    end

    trait :gold_rewards do
      association :rewards_tier, factory: %i[rewards_tier gold]
    end

    trait :platinum_rewards do
      association :rewards_tier, factory: %i[rewards_tier platinum]
    end

    trait :platinum_honors_rewards do
      association :rewards_tier, factory: %i[rewards_tier platinum_honors]
    end

    trait :gold_rewards_override do
      association :rewards_tier_override, factory: %i[rewards_tier gold]
    end

    trait :platinum_rewards_override do
      association :rewards_tier_override, factory: %i[rewards_tier platinum]
    end

    trait :platinum_honors_rewards_override do
      association :rewards_tier_override, factory: %i[rewards_tier platinum_honors]
    end
  end
end
