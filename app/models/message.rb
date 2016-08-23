# frozen_string_literal: true
class Message < ActiveRecord::Base
  belongs_to :thread, polymorphic: true
  belongs_to :sender, polymorphic: true
  belongs_to :recipient, polymorphic: true

  scope :preload_associations, -> { preload(:thread, :sender, :recipient) }
  scope :recent, -> { order(created_at: :desc) }
  scope :between, -> (type, id) {
    where(thread: nil)
      .where('(recipient_type = :type AND recipient_id = :id) OR (sender_type = :type AND sender_id = :id)',
             type: type, id: id.to_i)
  }

  include FileUploader[:file]

  validates :message, presence: true

  def self.threads_for(subject)
    query = <<-SQL
    WITH summary AS (
      SELECT *, ROW_NUMBER() OVER(PARTITION BY m.thread_id ORDER BY m.created_at DESC) AS n
      FROM messages AS m
    )
    SELECT DISTINCT(summary.thread_type, summary.thread_id), * FROM summary WHERE summary.n = 1 AND
      ((sender_type = :type AND sender_id = :id) OR
       (recipient_type = :type AND recipient_id = :id))
    ORDER BY summary.created_at DESC
    SQL
    find_by_sql([query, { id: subject.id, type: subject.model_name.name }])
  end

  def messages
    if thread
      Message.where(thread: thread)
    else
      same = '(recipient_type = :rcpt_type AND recipient_id = :rcpt_id AND
               sender_type = :sender_type AND sender_id = :sender_id)'
      reverse = '(recipient_type = :sender_type AND recipient_id = :sender_id AND
                  sender_type = :rcpt_type AND sender_id = :rcpt_id)'
      Message.where(thread: nil).where "#{same} OR #{reverse}",
                                       rcpt_type: recipient_type,
                                       rcpt_id: recipient_id,
                                       sender_type: sender_type,
                                       sender_id: sender_id
    end
  end

  def other_party(party)
    sender == party ? recipient : sender
  end

  def sender?(sender)
    self.sender == sender
  end

  def send!
    return false unless save
    # TODO: Send notification
    true
  end
end