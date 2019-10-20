class Mentor < ActiveRecord::Base
  has_one :trainee

  validates :name, presence: true
  validates :email, presence: true
  validates :phone, presence: true

  def trainee_id
    trainee.id
  end

  def info
    [name, email, phone].join(" - ")
  end
end
