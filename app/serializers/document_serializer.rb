# frozen_string_literal: true

class DocumentSerializer < ApplicationSerializer
  attributes :id,
             :owner_id,
             :owner_type,
             :uploadable_type,
             :uploadable_id,
             :file_data,
             :created_at,
             :updated_at,
             :url,
             :owner_name
  def url
    object.file_url
  end
end
