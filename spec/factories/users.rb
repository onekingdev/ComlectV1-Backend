# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    transient do
      email_prefix 'user'
    end

    sequence(:email) { |n| "#{n + rand(10_000)}@example.com" }
    password 'password'
    confirmed_at Time.now.utc

    jwt_hash { SecureRandom.hex(10) }

    before(:create) do |user, evaluator|
      user.email = "#{evaluator.email_prefix}#{user.email}"
    end

    after(:create) do |user, _evaluator|
      CookieAgreement.create(user: user, status: true)
      TosAgreement.create(user: user, status: true)
    end
  end
end
