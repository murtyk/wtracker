# one contact can have many emails
class ContactEmail < ActiveRecord::Base
  belongs_to :account
  belongs_to :email
  belongs_to :contact
end
