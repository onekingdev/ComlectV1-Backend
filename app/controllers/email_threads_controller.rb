# frozen_string_literal: true
class EmailThreadsController < ApplicationController
  skip_before_action :verify_authenticity_token
  # TODO: LAUNCH: remove this
  skip_before_action :beta_protection

  before_action -> {
    authenticated = authenticate_with_http_basic do |u, p|
      u == ENV.fetch('POSTMARK_INBOUND_USER') && p == ENV.fetch('POSTMARK_INBOUND_PASSWORD')
    end
    request_http_basic_authentication if !authenticated && Rails.env.production?
  }

  def create
    thread_key, sender = message_hashes
    return render(nothing: true, status: :ok) if thread_key.nil? # Blackhole for spam (could also hide a bug?)
    required_params = [params.require('TextBody'), params.require('HtmlBody'), params.require('StrippedTextReply')]
    MessageMailer.deliver_later :reply,
                                EmailThread.find_by!(thread_key: thread_key),
                                sender,
                                *required_params
    render nothing: true, status: :ok
  end

  private

  # http://developer.postmarkapp.com/developer-inbound-webhook.html
  def message_hashes
    inbound = ENV.fetch('POSTMARK_INBOUND_ADDRESS').split('@')[0]
    to = params.require('ToFull').detect { |t| t['Email'].to_s.starts_with?(inbound) } || {}
    return [] if to.nil?
    hash = to.fetch('MailboxHash')
    [hash[0..-2], hash[-1]] # abcde01234b = [abcde01234, b] (thread key and b=business s=specialist)
  end
end
