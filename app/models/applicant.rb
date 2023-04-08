include UtilitiesHelper
# applicant
class Applicant < ApplicationRecord
  include Humanizer

  default_scope { where(account_id: Account.current_id) }

  store_accessor :data, :skills,
                 :unemployment_proof_initial,
                 :unemployment_proof_date,
                 :skip_resume,
                 :unique_id

  attr_accessor :salt, :bypass_humanizer, :email_confirmation
  attr_accessor :latitude, :longitude
  attr_accessor :reapply_key

  require_human_on :create, unless: :bypass_humanizer

  before_save :cb_before_save

  has_one :agent, as: :identifiable, dependent: :destroy

  has_many :applicant_special_services, dependent: :destroy
  has_many :special_services, through: :applicant_special_services

  has_many :applicant_reapplies, dependent: :destroy

  belongs_to :account
  belongs_to :county
  belongs_to :education, foreign_key: :education_level
  belongs_to :grant
  belongs_to :race
  belongs_to :sector
  belongs_to :trainee

  delegate :dob, :edp_date, :assessed?, :assigned_to_klass?,
           to: :trainee, prefix: true, allow_nil: true

  delegate :name,  to: :county,    prefix: true, allow_nil: true
  delegate :name,  to: :education, prefix: true, allow_nil: true
  delegate :name,  to: :sector,    prefix: true, allow_nil: true

  delegate :ethnicity,                      to: :race,      allow_nil: true
  delegate :funding_source_name, :login_id, :placement_status,
           to: :trainee, allow_nil: true

  validates :first_name, presence: true, length: { minimum: 2, maximum: 20 }
  validates :last_name,  presence: true, length: { minimum: 2, maximum: 20 }
  validates :address_line1, presence: true, length: { minimum: 5, maximum: 50 }
  validates :address_city,  presence: true, length: { minimum: 3, maximum: 30 }
  validates_format_of :address_zip,
                      with: /\d{5}/,
                      message: 'is invalid, should be 5 digits'
  validates :address_zip,
            presence: true,
            length: { is: 5,
                      wrong_length: 'is the wrong length (should be 5 digits)' }

  validates :grant,  presence: true
  validates_uniqueness_of :email, scope: :grant_id, case_sensitive: false
  validate :validate_applicant_data

  validates_format_of :unique_id,
                      with: /\d{9}/,
                      message: 'is invalid, should be 9 digits'

  after_initialize :init

  def init
    self.address_state ||= Account.current_account.states.first.code
  end

  def employment_status_pre_selected?
    return false unless current_employment_status
    es = EmploymentStatus.where(status: current_employment_status).first
    es && es.pre_selected
  end

  def week
    created_at.strftime('%Y-%W')
  end

  def name
    first_name + ' ' + last_name
  end

  def mobile_phone_number
    format_phone_no(mobile_phone_no)
  end

  def placement_details
    trainee.trainee_placements.map(&:details).join('<br>').html_safe
  end

  def address
    br = '<br>'
    addr = address_line1 + br +
           (address_line2.blank? ? '' : (address_line2 + br)) +
           address_city_state_zip + br +
           "county: <strong>#{county_name}</strong>"
    addr.html_safe
  end

  def address_city_state_zip
    address_city + ', ' + address_state + ' ' + address_zip
  end

  def gender_text
    gender.to_i == 1 ? 'Male' : 'Female'
  end

  def accepted?
    status == 'Accepted'
  end

  def declined?
    status == 'Declined'
  end

  def status_can_change?
    !(accepted? || declined?)
  end

  def self.statuses
    %w(Accepted Declined None)
  end

  def self.employment_statuses
    [%w(Accept Accepted), %w(Decline Declined), %w(None None)]
  end

  belongs_to :navigator, class_name: 'User', foreign_key: 'navigator_id'

  def navigator_name
    (navigator && navigator.name).to_s
  end

  def last_employer_address
    street = last_employer_line1
    street += last_employer_line2.blank? ? '' : ('<br>' + last_employer_line2)
    [street, last_employer_city,
     last_employer_state + ' ' + last_employer_zip].join('<br>').html_safe
  end

  def last_employer_contact
    (last_employer_manager_name + '<br>' +
     last_emp_formatted_phone + '<br>' +
     last_emp_email +
     last_employer_address).html_safe
  end

  def last_emp_formatted_phone
    format_phone_no(last_employer_manager_phone_no)
  end

  def last_emp_email
    return '' unless last_employer_manager_email
    last_employer_manager_email.to_s + '<br>'
  end

  def special_services_requested
    '<ol>' +
      special_services.pluck(:name).map { |ss| "<li>#{ss}</li>" }.join('') +
      '</ol>'
  end

  def veteran?
    veteran ? 'Yes' : 'No'
  end

  def legal_status_text
    Trainee::LEGAL_STATUSES[legal_status]
  end

  def transportation?
    transportation ? 'Yes' : 'No'
  end

  def computer_access?
    computer_access ? 'Yes' : 'No'
  end

  def assigned_klass?
    trainee.klasses.any?
  end

  def valid_address?
    latitude && longitude
  end

  def recent_ra
    @recent_ra ||= applicant_reapplies.last
  end

  def reapply_key
    recent_ra && !recent_ra.used? && recent_ra.key
  end

  def reapply?(key)
    reapply_key == key
  end

  def void_reapplication
    return unless recent_ra
    recent_ra.update(used: true)
    update(applied_on: recent_ra.updated_at.to_date)
  end

  delegate :email_subject, :email_body, to: :employment_status

  private

  def allowed_blank_attrs # also includes false values ex: veteran true or false
    %w(id trainee_id navigator_id comments status type address_line2
       transportation computer_access veteran applied_on
       created_at updated_at last_employer_line2 last_employer_manager_email)
  end

  def non_bool_attributes
    attributes.keys - allowed_blank_attrs
  end

  def validate_applicant_data
    msg = "can't be blank"
    non_bool_attributes.each { |at| errors.add(at, msg) if send(at).blank? }

    validate_boolean_attributes
    validate_self_services
    validate_email
    validate_phone_numbers
    validate_skills

    errors.empty?
  end

  def cb_before_save
    self.mobile_phone_no = mobile_phone_no.delete('^0-9') if mobile_phone_no
    if last_employer_manager_phone_no
      p = last_employer_manager_phone_no.delete('^0-9')
      self.last_employer_manager_phone_no = p
    end
    self.status = employment_status.action
    self.applied_on ||= Date.current
  end

  def employment_status
    EmploymentStatus.where(status: current_employment_status).first
  end

  def validate_boolean_attributes
    %w(transportation computer_access veteran).each do |at|
      errors.add(at, "can't be blank") if send(at).nil?
    end
  end

  def validate_email
    valid_email = valid_email_parts?
    errors.add(:email, 'invalid email address') unless valid_email
    if new_record? && email.downcase != email_confirmation.downcase
      errors.add(:email_confirmation, 'does not match email')
      valid_email = false
    end
    valid_email
  end

  def valid_email_parts?
    parts = email.to_s.split('@')
    return false unless parts.count == 2

    parts = parts[1].split('.')
    parts.count > 1
  end

  def validate_phone_numbers
    validate_mobile_phone_no
    validate_emp_phone_no
  end

  def validate_mobile_phone_no
    return if mobile_phone_no.blank?
    phone = mobile_phone_no.delete('^0-9')
    return unless phone.size < 10
    errors.add(:mobile_phone_no, 'Should contain minimum 10 digits')
  end

  def validate_emp_phone_no
    return if last_employer_manager_phone_no.blank?

    phone = last_employer_manager_phone_no.delete('^0-9')
    errors.add(:last_employer_manager_phone_no,
               'Should contain minimum 10 digits') if phone.size < 10
  end

  def validate_self_services
    return unless applicant_special_services.empty?
    errors.add('special_services', 'You have to select at least 1 option')
  end

  def validate_skills
    size = skills.to_s.size
    return true if size > 0 && size < 421
    errors.add(:skills, "can't be blank") if skills.blank?
    errors.add(:skills, "size(#{size}) exceeds 420 characters.") if size > 420
    false
  end
end
