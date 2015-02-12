include UtilitiesHelper
# applicant
class Applicant < ActiveRecord::Base
  include Humanizer

  default_scope { where(account_id: Account.current_id) }
  attr_accessible :first_name, :last_name, :email, :address_line1, :address_line2,
                  :address_city, :address_state, :address_zip, :mobile_phone_no,
                  :last_employed_on, :current_employment_status, :last_job_title,
                  :salary_expected, :education_level, :transportation,
                  :computer_access, :comments, :county_id, :legal_status, :veteran,
                  :last_employer_name, :last_employer_city, :last_employer_state,
                  :last_employer_line1, :last_employer_line2, :last_employer_zip,
                  :last_employer_manager_name, :last_employer_manager_phone_no,
                  :last_employer_manager_email, :resume, :source, :signature, :status,
                  :salt, :humanizer_answer, :humanizer_question_id,
                  :trainee_id, :navigator_id, :sector_id, :race_id, :last_wages,
                  :gender, :unemployment_proof, :special_service_ids, :reapply_key

  attr_accessor :salt, :bypass_humanizer, :funding_source_id, :klass_id
  attr_accessor :latitude, :longitude
  attr_accessor :reapply_key

  require_human_on :create, unless: :bypass_humanizer

  delegate :funding_source_name, :login_id, to: :trainee, allow_nil: true

  after_initialize :init_values
  before_save :cb_before_save

  has_one :agent, as: :identifiable, dependent: :destroy

  has_many :applicant_special_services, dependent: :destroy
  has_many :special_services, through: :applicant_special_services
  accepts_nested_attributes_for :special_services

  has_many :applicant_reapplies

  belongs_to :race
  belongs_to :account
  belongs_to :grant
  belongs_to :trainee
  belongs_to :sector
  belongs_to :county
  validates :grant,  presence: true
  validates_uniqueness_of :email, scope: :grant_id
  validate :validate_applicant_data

  def week
    created_at.strftime('%Y-%W')
  end

  def name
    first_name + ' ' + last_name
  end

  def mobile_phone_number
    format_phone_no(mobile_phone_no)
  end

  def county_name
    county.name
  end

  def sector_name
    sector.name
  end

  def applied_on
    ra = applicant_reapplies.where(used: true).last
    return ra.updated_at.to_date.to_s if ra
    created_at.to_date.to_s
  end

  def placement_details
    trainee.trainee_placements.map do |tp|
      tp.details
    end.join('<br>').html_safe
  end

  def address
    br = '<br>'
    addr = address_line1 + br +
           (address_line2.blank? ? '' : (address_line2 + br)) +
           address_city + ', ' + address_state + ' ' + address_zip + br +
           "county: <strong>#{county_name}</strong>"
    addr.html_safe
  end

  def gender_text
    gender.to_i == 1 ? 'Male' : 'Female'
  end

  def education
    Education.find(education_level).name
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
    [
      %w(Accept Accepted),
      %w(Decline Declined),
      %w(None None)
    ]
  end

  def next
    app = Applicant.where(status: 'Accepted')
    app.where('id > ?', id).order(:id).first || app.order(:id).first
  end

  belongs_to :navigator, class_name: "User", foreign_key: 'navigator_id'

  def navigator_name
    navigator && navigator.name
  end

  def last_employer_address
    street = last_employer_line1
    street += last_employer_line2.blank? ? '' : ('<br>' + last_employer_line2)
    [street, last_employer_city,
     last_employer_state + ' ' + last_employer_zip].join('<br>').html_safe
  end

  def last_employer_contact
    (last_employer_manager_name + '<br>' +
     format_phone_no(last_employer_manager_phone_no) + '<br>' +
     (last_employer_manager_email && (last_employer_manager_email.to_s + '<br>')) +
     last_employer_address).html_safe
  end

  def ethnicity
    race.name
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

  def reapply_key
    ar = applicant_reapplies.last
    ar && !ar.used? && ar.key
  end

  def reapply?(key)
    ar = applicant_reapplies.last
    ar && !ar.used? && ar.key == key
  end

  def void_reapplication
    ar = applicant_reapplies.last
    if ar
      ar.used = true
      ar.save
    end
  end
  delegate :email_subject, :email_body, to: :employment_status



  private

  def allowed_blank_attrs # also includes false values ex: veteran true or false
    %w(id trainee_id navigator_id comments status type address_line2
       transportation computer_access veteran
       created_at updated_at last_employer_line2 last_employer_manager_email)
  end

  def validate_applicant_data
    attrs = attributes.keys - allowed_blank_attrs

    attrs.each { |at| errors.add(at, "can't be blank") if send(at).blank? }

    %w(transportation computer_access veteran).each do |at|
      errors.add(at, "can't be blank") if send(at).nil?
    end

    if applicant_special_services.empty?
      errors.add('special_services', 'You have to select at least 1 option')
    end

    validate_email
    validate_phone_numbers

    errors.empty?
  end

  def init_values
    self.address_state = account.state_code
    @funding_source_id = trainee && trainee.funding_source_id
  end

  def cb_before_save
    self.mobile_phone_no = mobile_phone_no.delete('^0-9') if mobile_phone_no
    if last_employer_manager_phone_no
      p = last_employer_manager_phone_no.delete('^0-9')
      self.last_employer_manager_phone_no = p
    end
    self.status = employment_status.action
  end

  def employment_status
    EmploymentStatus.where(status: current_employment_status).first
  end

  def validate_email
    parts = email.to_s.split('@')
    valid_email = parts.count == 2
    if valid_email
      parts = parts[1].split('.')
      valid_email = parts.count > 1
    end
    errors.add(:email, 'invalid email address') unless valid_email
    valid_email
  end

  def validate_phone_numbers
    unless mobile_phone_no.blank?
      phone = mobile_phone_no.delete('^0-9')
      errors.add(:mobile_phone_no, 'Should contain minimum 10 digits') if phone.size < 10
    end

    unless last_employer_manager_phone_no.blank?
      phone = last_employer_manager_phone_no.delete('^0-9')
      errors.add(:last_employer_manager_phone_no,
                 'Should contain minimum 10 digits') if phone.size < 10
    end
  end
end
