# frozen_string_literal: true
class Jurisdiction < ActiveRecord::Base
  has_and_belongs_to_many :businesses
end
