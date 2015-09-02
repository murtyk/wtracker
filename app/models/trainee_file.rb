# s3 file name
class TraineeFile < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }

  belongs_to :trainee
  attr_accessible :file, :notes, :uploaded_by, :trainee_id # permitted
  attr_accessor :unemployment_proof_initial, :unemployment_proof_date
  before_destroy :cb_before_destroy

  def name
    Amazon.original_file_name(file)
  end

  private

  def cb_before_destroy
    Amazon.delete_file(file)
  end
end
