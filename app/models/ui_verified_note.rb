class UiVerifiedNote < ActiveRecord::Base
  belongs_to :user
  belongs_to :trainee
  validates :notes, presence: true, length: { minimum: 3 }
end
