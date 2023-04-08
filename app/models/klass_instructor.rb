# instructors assigned to a class
class KlassInstructor < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }
  belongs_to :klass
  belongs_to :user

  delegate :name, :email, :land_no?, :land_no, :ext,
           :mobile_no?, :mobile_no, to: :user

  validates :user, presence: true
end
