# frozen_string_literal: true
class Specialist::Form < Specialist
  include ApplicationForm

  validates :first_name, :last_name, :country, :zipcode, presence: true
  validate :validate_photo, :validate_resume

  accepts_nested_attributes_for :user

  attr_accessor :public_profile

  def self.signup(attributes = {})
    new(attributes).tap do |specialist|
      specialist.build_user unless specialist.user
      specialist.work_experiences.build unless specialist.work_experiences.any?
      specialist.education_histories.build unless specialist.education_histories.any?
    end
  end

  def public_profile
    @public_profile.nil? ? public? : @public_profile
  end

  def public_profile=(is_public)
    @public_profile = is_public
    self.visibility = is_public ? visibilities(:is_public) : visibilities(:is_private)
  end

  private

  # Shrine validations are not firing for some reason
  def validate_photo
    if photo && photo_data_changed?
      errors.add :photo, :too_large if photo.metadata['size'] > 2.megabytes
      errors.add :photo, :invalid unless %w(image/jpeg image/png image/gif).include?(photo.metadata['mime_type'])
    end
  end

  def validate_resume
    if resume && resume_data_changed?
      errors.add :resume, :too_large if resume.metadata['size'] > 2.megabytes
      errors.add :resume, :invalid unless %w(application/pdf).include?(resume.metadata['mime_type'])
    end
  end
end
