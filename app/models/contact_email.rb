# frozen_string_literal: true

# one contact can have many emails
class ContactEmail < ApplicationRecord
  belongs_to :account
  belongs_to :email
  belongs_to :contact
end
