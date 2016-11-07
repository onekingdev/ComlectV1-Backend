# frozen_string_literal: true
class Metrics::Financials
  include ActiveSupport::NumberHelper
  include ActionView::Helpers::TextHelper
  include Metrics::Financials::Actual

  attr_reader :metrics

  def initialize
    @db_view = begin
                 ActiveRecord::Base.connection.execute('SELECT * FROM financials').to_a
               rescue
                 nil
               end
  end

  def invalid?
    @db_view.nil?
  end

  def to_csv
    CSV.generate do |csv|
      csv << %w(metric mtd fytd itd all_periods)
      [actual, forecast].each do |set|
        csv_from_hash(hash: set).each_slice(4).each do |row|
          csv << row + [nil]
        end
      end
      add_postings_csv csv
    end
  end

  private

  def add_postings_csv(csv)
    activity = Metrics::Financials::Postings.new.postings
    csv_from_hash(hash: activity, value_cols: 2).each_slice(3).each do |row|
      csv << [row[0], nil, nil, nil, row[1]]
    end
  end

  def csv_from_hash(hash:, prefix: '', value_cols: 3)
    hash.map do |label, row|
      label_with_prefix = "#{prefix.present? ? "#{prefix} / " : ''}#{label}"
      next if row.all?(&:nil?)
      if row.size == value_cols
        [label_with_prefix, *row]
      else
        csv_from_hash hash: row[-1], prefix: label_with_prefix, value_cols: value_cols
      end
    end.flatten
  end

  # rubocop:disable Metrics/AbcSize
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
    when :days
      results.map { |r| pluralize(r.to_f.round, 'day', 'days') }
    else
      results.map(&:to_i)
    end
  end
end
