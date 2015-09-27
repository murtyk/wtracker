# email to employers
# trianee documents can be attached
# additional documents can be attached
class Email < ActiveRecord::Base
  serialize :trainee_file_ids
  default_scope { where(account_id: Account.current_id) }

  belongs_to :account
  belongs_to :user
  attr_accessor :klass_id, :contact_ids

  has_many :contact_emails, dependent: :destroy
  has_many :contacts, through: :contact_emails
  has_many :attachments, dependent: :destroy
  has_many :trainee_submits
  # do not destroy dependent since we need to track this

  validates :subject, presence: true, length: { minimum: 5 }
  validates :content, presence: true, length: { minimum: 5 }
  validates :contact_emails, presence: true

  def attachment_names
    TraineeFile.where(id: trainee_file_ids).map(&:name) +
      attachments.pluck(:name)
  end

  def sender
    "#{user.name}<#{user.email}>"
  end

  def sender_email_address
    user.email
  end

  def contact_names_for_selection
    return [] unless contact_ids
    Contact.where(id: contact_ids).map { |c| [c.name_for_selection, c.id] }
  end
end
