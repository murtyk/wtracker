# frozen_string_literal: true

# s3 file name
class TraineeFile < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }

  belongs_to :trainee

  attr_accessor :unemployment_proof_initial,
                :unemployment_proof_date,
                :skip_resume

  before_destroy :cb_before_destroy

  def name
    Amazon.original_file_name(file)
  end

  private

  def cb_before_destroy
    Amazon.delete_file(file)
  end
end
