# notes on a trainee
class TraineeNote < ActiveRecord::Base
  attr_accessible :notes, :trainee_id
  belongs_to :trainee
  validates :notes, presence: true, length: { minimum: 3 }
  def date_and_notes
    "#{created_at.to_date} - #{notes}"
  end
end
