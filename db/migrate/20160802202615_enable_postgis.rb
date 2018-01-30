# frozen_string_literal: true

class EnablePostgis < ActiveRecord::Migration
  # rubocop:disable Lint/HandleExceptions
  def change
    enable_extension 'postgis'
  rescue PG::UniqueViolation
  end
  # rubocop:enable Lint/HandleExceptions
end
