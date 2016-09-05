# frozen_string_literal: true
class StripeAccount < ActiveRecord::Base
  belongs_to :specialist

  include FileUploader[:verification_document]

  enum status: { pending: 'Pending', verified: 'Verified', error: 'Error' }
end
