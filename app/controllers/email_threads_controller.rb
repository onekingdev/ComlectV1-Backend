# frozen_string_literal: true
class EmailThreadsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action -> {
    authenticated = authenticate_with_http_basic do |u, p|
      u == ENV.fetch('POSTMARK_INBOUND_USER') && p == ENV.fetch('POSTMARK_INBOUND_PASSWORD')
    end
    request_http_basic_authentication if !authenticated && Rails.env.production?
  }

  def create
    thread_key, sender = message_hashes
    thread = EmailThread.find_by!(thread_key: thread_key)
    MessageMailer.deliver_later :reply, thread, sender, params['TextBody'], params['HtmlBody']
    render nothing: true, status: :ok
  end

  private

  # http://developer.postmarkapp.com/developer-inbound-webhook.html
  def message_hashes
    inbound = ENV.fetch('POSTMARK_INBOUND_ADDRESS').split('@')[0]
    to = params.require('ToFull').detect { |t| t['Email'].to_s.starts_with?(inbound) } || {}
    to.fetch('MailboxHash').split('+')
  end
end
