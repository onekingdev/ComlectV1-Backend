# frozen_string_literal: true

class AddHubspotContactId < ActiveRecord::Migration[6.0]
  def change
    add_column :businesses, :hubspot_contact_id, :string
    add_column :specialists, :hubspot_contact_id, :string
  end
end
