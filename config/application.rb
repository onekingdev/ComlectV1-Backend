# frozen_string_literal: true

require File.expand_path('boot', __dir__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Complect
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.eager_load_paths << Rails.root.join('lib')

    config.action_mailer.default_url_options = { host: ENV.fetch('DEFAULT_URL_HOST') }

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    # SQL schema to take advantage of pg's more advanced features
    config.active_record.schema_format = :sql

    config.generators do |generate|
      generate.assets false
      generate.helper false
      generate.view_specs false
      generate.helper_specs false
      generate.decorator false
    end

    # Use Sidekiq for asynchronous operations.
    config.active_job.queue_adapter = :sidekiq

    config.middleware.insert_before 0, 'Rack::Cors' do
      allow do
        origins(/https:\/\/.+?\.complect\.com?/)
        resource '*', headers: :any, methods: :get
      end
    end
  end
end
