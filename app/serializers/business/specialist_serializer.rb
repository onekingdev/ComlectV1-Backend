# frozen_string_literal: true

class Business::SpecialistSerializer < ApplicationSerializer
  has_many :skills, serializer: SkillSerializer
  has_many :jurisdictions, serializer: JurisdictionSerializer
  has_many :industries, serializer: IndustrySerializer
  has_many :specialists_business_roles
  has_many :work_experiences
  attributes :id,
             :photo,
             :first_name,
             :last_name,
             :former_regulator,
             :resume_url,
             :certifications,
             :visibility,
             :ratings_count,
             :ratings_total,
             :ratings_average,
             :time_zone,
             :username,
             :experience,
             :min_hourly_rate,
             :location,
             :seat_role,
             :city,
             :state,
             :description,
             :specialist_other,
             :plan

  def photo
    object.photo_url(:thumb)
  end

  def location
    [object.city, object.state, object.country].map(&:presence).compact.join(', ')
  end
end
