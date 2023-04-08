# email attachment which gets stored on s3
# on delete, we should delete on s3 also
class Attachment < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }
  before_destroy :cb_before_destroy

  belongs_to :account
  belongs_to :email

  private

  def cb_before_destroy
    Amazon.delete_file(file)
  end
end
