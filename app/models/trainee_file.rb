# s3 file name
class TraineeFile < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }

  belongs_to :trainee
  attr_accessible :file, :notes, :uploaded_by, :trainee_id # permitted
  before_destroy :cb_before_destroy

  def name
    Amazon.original_file_name(file)
  end

  private

  def cb_before_destroy
    Amazon.delete_file(file)
  end
end
