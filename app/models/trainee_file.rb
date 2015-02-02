# s3 file name
class TraineeFile < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }

  belongs_to :trainee
  attr_accessible :file, :notes, :uploaded_by, :trainee_id
  before_destroy :cb_before_destroy

  def name
    file_parts = file.split('/')
    bare_name = file_parts[-1]
    bare_name[12..-1]
  end

  private

  def cb_before_destroy
    Amazon.delete_file(file)
  end
end
