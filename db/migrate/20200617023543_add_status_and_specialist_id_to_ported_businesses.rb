# frozen_string_literal: true

class AddStatusAndSpecialistIdToPortedBusinesses < ActiveRecord::Migration
  def change
    add_column :ported_businesses, :status, :string, default: 'pending'
    add_column :ported_businesses, :specialist_id, :integer, default: nil
  end
end
