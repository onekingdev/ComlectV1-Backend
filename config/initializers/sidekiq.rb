# frozen_string_literal: true
Sidekiq.default_worker_options = {
  unique: :until_and_while_executing,
  unique_args: -> (args) { args.first.except('job_id') }
}

# https://devcenter.heroku.com/articles/forked-pg-connections#sidekiq
Sidekiq.configure_server do |config|
  if (database_url = ENV['DATABASE_URL'])
    ENV['DATABASE_URL'] = "#{database_url}?pool=#{ENV['SIDEKIQ_CONCURRENCY']}"
    ActiveRecord::Base.establish_connection
  end

  config.redis = { size: 27 }
end

Sidekiq.configure_client do |config|
  # 1 connection per Rails process
  config.redis = { size: 1 }
end

SidekiqUniqueJobs.config.unique_args_enabled = true

schedule_file = Rails.root.join('config/schedule.yml')
if File.exist?(schedule_file)
  schedule = YAML.load_file(schedule_file)
  Sidekiq::Cron::Job.load_from_hash schedule
end
