# frozen_string_literal: true

class Api::DirectMessagesController < ApiController
  before_action :require_someone!
  skip_before_action :verify_authenticity_token

  def show
    messages = Message.where(sender: @current_someone).where.not(recipient: nil)
      .or(Message.where(recipient: @current_someone).where.not(recipient: nil))
      .direct.order('id asc').select(:recipient_id, :read_by_recipient, :message, :recipient_type, :sender_id, :sender_type)

    recipients = {}

    messages.each do |msg|
      im_sender = msg.sender_type == (@current_someone.class.name.include?('Business') ? 'Business' : 'Specialist')
      tgt_recipient_id = im_sender ? msg.recipient_id : msg.sender_id
      recipients[tgt_recipient_id] = { total: 0, unread: 0, last: '' } unless recipients.key?(tgt_recipient_id)
      recipients[tgt_recipient_id][:total] += 1
      recipients[tgt_recipient_id][:unread] += 1 if !im_sender && !msg.read_by_recipient
      recipients[tgt_recipient_id][:last] = msg.message
    end

    recipients_db = @current_someone.class.name.include?('Business') ? serialize_specialists(Specialist.where(id: recipients.keys)) : serialize_businesses(Business.where(id: recipients.keys))

    render json: { chats: recipients, recipients: recipients_db }.to_json
  end

  def index
    bid, sid = if @current_someone.class.name.include?('Business')
      [@current_someone.id,
       Specialist.find(params[:recipient_id])]
    elsif @current_someone.class.name.include?('Specialist')
      [Business.find(params[:recipient_id]),
       @current_someone.id]
    end

    messages = Message.order('id asc').business_specialist(bid, sid).direct.includes(:sender, :recipient).page(params[:page]).per(20)
    mark_read_ids = []
    messages.each do |msg|
      mark_read_ids.push msg.id if msg.sender != @current_someone
    end
    Message.where(id: mark_read_ids).update_all(read_by_recipient: true)
    respond_with messages, each_serializer: MessageSerializer
  end

  def create
    if message_params[:message].nil? && message_params[:file].nil?
      render json: { errors: I18n.t('api.direct_messages.empty_message') }
      return
    end

    recipient = if @current_someone.class.name.include? 'Business'
      Specialist.find(params[:recipient_id])
    elsif @current_someone.class.name.include? 'Specialist'
      Business.find(params[:recipient_id])
    end

    message = Message::Create.call(nil, message_params.merge(sender: @current_someone, recipient: recipient), @current_someone, recipient)
    if !message.nil?
      respond_with message, serializer: MessageSerializer
    else
      render json: { errors: message.errors.to_json }
    end
  end

  private

  def serialize_specialists(specialists)
    specialists.map(&proc { |specialist| Business::SpecialistSerializer.new(specialist).serializable_hash })
  end

  def serialize_businesses(businesses)
    businesses.map(&proc { |business| Specialist::BusinessSerializer.new(business).serializable_hash })
  end

  def message_params
    params.require(:message).permit(:message, :file)
  end
end
