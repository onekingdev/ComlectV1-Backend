# frozen_string_literal: true

class BusinessSerializer < ApplicationSerializer
  attributes :id,
             :contact_first_name,
             :contact_last_name,
             :business_name,
             :country,
             :city,
             :state,
             :jurisdictions,
             :industries,
             :crd_number,
             :sub_industries,
             :username,
             :aum,
             :apartment,
             :client_account_cnt,
             :address_1,
             :address_2,
             :website,
             :contact_phone,
             :zipcode,
             :time_zone,
             :plan,
             :logo,
             :photo,
             :user_email
  has_many :jurisdictions, serializer: JurisdictionSerializer
  has_many :industries, serializer: IndustrySerializer

  def logo
    object.logo_url(:profile)
  end

  def photo
    object.photo_url(:profile)
  end

  def user_email
    object.user.email
  end
end
