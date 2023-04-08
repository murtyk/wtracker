class Mentor < ApplicationRecord
  has_one :trainee

  validates :name, presence: true

  def trainee_id
    trainee.id
  end

  def info
    [name, email.presence, phone.presence].compact.join(' - ')
  end
end
