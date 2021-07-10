# frozen_string_literal: true

class AddAddressFieldsToSpecialists < ActiveRecord::Migration[6.0]
  def change
    add_column :specialists, :address_1, :string
    add_column :specialists, :address_2, :string
  end
end
