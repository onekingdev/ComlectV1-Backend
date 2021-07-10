# frozen_string_literal: true

class AddPdfToArticles < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :pdf_data, :jsonb
    add_column :articles, :open_pdf, :boolean, default: false
  end
end
