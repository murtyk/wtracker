# frozen_string_literal: true

class UiVerifiedNote < ApplicationRecord
  belongs_to :user
  belongs_to :trainee
  validates :notes, presence: true, length: { minimum: 3 }
end
