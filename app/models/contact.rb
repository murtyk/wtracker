# an Employer can have contacts.
# Contact provides contactable interface
# so can be used for contacts at other entities
class Contact < ActiveRecord::Base
  include ValidationsMixins
  default_scope { where(account_id: Account.current_id) }

  before_save :cb_before_save

  belongs_to :account
  belongs_to :contactable, polymorphic: true

  has_many :contact_emails, dependent: :destroy

  validates :first, presence: true
  validates :last, presence: true
  validate :validate_email

  def name_for_selection
    "#{name} (#{contactable.name})"
  end

  def name
    (first || '') + ' ' + (last || '')
  end

  # def self.new_with_contactable(params)
  #   owner_class = Object.const_get(params[:contactable_type])
  #   owner_instance = owner_class.find(params[:contactable_id])
  #   params.delete :contactable_type
  #   params.delete :contactable_id
  #   params[:land_no] = owner_instance.phone_no unless params[:land_no]
  #   owner_instance.contacts.new(params)
  # end

  private

  def cb_before_save
    self.land_no = land_no && land_no.delete('^0-9')
    self.mobile_no = mobile_no && mobile_no.delete('^0-9')
  end
end
