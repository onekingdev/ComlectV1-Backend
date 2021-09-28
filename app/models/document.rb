# frozen_string_literal: true

class Document < ApplicationRecord
  include FileUploader[:file]
  belongs_to :owner, polymorphic: true, optional: true
  belongs_to :uploadable, polymorphic: true, optional: true
  validates :file_data, presence: true
  belongs_to :specialist, optional: true # recipient if uploaded by business @ interview

  delegate :name, to: :owner, prefix: true

  def file_name
    file_data['metadata']['filename']
  end
end
