# frozen_string_literal: true

Stripe.api_key = ENV.fetch('STRIPE_SECRET_KEY')
Stripe.api_version = '2019-12-03'
