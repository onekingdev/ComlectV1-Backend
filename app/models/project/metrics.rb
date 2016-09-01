# frozen_string_literal: true
class Project::Metrics
  include ActiveSupport::NumberHelper

  attr_reader :metrics

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def initialize
    @db_view = ActiveRecord::Base.connection.execute('SELECT * FROM metrics').to_a
    @metrics = {
      'Projects' => [nil, nil, nil, {
        'Number Posted' => metric('projects_posted'),
        'Average Value' => metric('projects_value', :currency),
        'Percent of All Postings' => metric('projects_share', :percentage),
        'Percent Hourly' => metric('projects_hourly_share', :percentage),
        'Percent Fixed' => metric('projects_fixed_share', :percentage),
        'By Payment Plan' => [nil, nil, nil, {
          'Hourly' => [*metric('projects_hourly_pay'), {
            'Upon Completion' => metric('projects_hourly_upon_completion_pay'),
            'Bi-Weekly' => metric('projects_hourly_bi_weekly_pay'),
            'Monthly' => metric('projects_hourly_monthly_pay')
          }],
          'Fixed' => [*metric('projects_fixed_pay'), {
            '50/50' => metric('projects_fixed_50_50_pay'),
            'Upon Completion' => metric('projects_fixed_upon_completion_pay'),
            'Bi-Weekly' => metric('projects_fixed_bi_weekly_pay'),
            'Monthly' => metric('projects_fixed_monthly_pay')
          }]
        }]
      }],
      'Jobs' => [nil, nil, nil, {
        'Number Posted' => metric('jobs_posted'),
        'Average Value' => metric('jobs_value', :currency),
        'Percent of All Postings' => metric('jobs_share', :percentage),
        'By Payment Plan' => [nil, nil, nil, {
          'Bi-Weekly' => metric('jobs_upfront_pay'),
          'Monthly' => metric('jobs_installment_pay')
        }]
      }]
    }
  end

  private

  def metric(name, cast = :int)
    values = @db_view.detect { |metric| metric['metric'] == name }
    results = [values['mtd'], values['fytd'], values['itd']]
    case cast
    when :float
      results.map { |r| r.to_f.round(2) }
    when :percentage
      results.map { |r| "#{r.to_f.round(2)}%" }
    when :currency
      results.map(&method(:number_to_currency))
    else
      results.map(&:to_i)
    end
  end
end
