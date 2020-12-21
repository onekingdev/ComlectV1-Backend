# frozen_string_literal: true

class RemoveRegulatoryChangesFromAnnualReports < ActiveRecord::Migration[6.0]
  def change
    remove_column :annual_reports, :regulatory_change
    remove_column :annual_reports, :regulatory_response
  end
end
