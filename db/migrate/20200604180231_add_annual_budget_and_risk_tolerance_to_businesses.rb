# frozen_string_literal: true

class AddAnnualBudgetAndRiskToleranceToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :annual_budget, :decimal, default: nil
    add_column :businesses, :risk_tolerance, :string, default: nil
  end
end
