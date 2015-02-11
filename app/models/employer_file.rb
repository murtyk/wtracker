# model for managing employer documents
class EmployerFile < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }
  belongs_to :account
  belongs_to :employer
  belongs_to :user

  attr_accessible :file, :notes, :user_id, :employer_id
  before_destroy :cb_before_destroy

  # original file name
  def name
    Amazon.original_file_name(file)
  end

  private

  # delete s3 file when this is destroyed
  def cb_before_destroy
    Amazon.delete_file(file)
  end
end
