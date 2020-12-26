# frozen_string_literal: true

class CreateDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :documents do |t|
      t.references :owner, index: true, polymorphic: true
      t.references :project, index: true, null: false
      t.jsonb :file_data

      t.timestamps null: false
    end
  end
end
