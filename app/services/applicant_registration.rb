# To process registered applicant
# Meant as a background process so that applicant gets fast response
# Trainee and other objects are created in background a notification
#   will be sent to TAPO admin on error
# A notification will be sent to applicant
class ApplicantRegistration
  attr_accessor :applicant_id, :account_id, :grant_id, :applicant, :grant

  def initialize(id, a_id = Account.current_id, g_id = Grant.current_id)
    @applicant_id = id
    @grant_id = g_id
    @account_id = a_id
    Rails.logger.info "Applicant registered. id = #{applicant_id}"
  end

  def process
    Rails.logger.info "Applicant registration process started. id = #{applicant_id}"
    init
    ok = true
    ok = create_objects if applicant.accepted?
    notify_applicant if ok
    notify_password if ok && applicant.accepted?
  end

  private

  def init
    Account.current_id = account_id
    Grant.current_id = grant_id
    @grant = Grant.find grant_id
    @applicant = Applicant.find applicant_id
  end

  def create_objects
    geocode_applicant
    trainee = create_trainee_from_applicant
    if trainee.errors.any?
      error = trainee.errors.full_messages[0]
      notify_tapo_admin(error)
      return false
    end
    applicant.trainee_id = trainee.id
    applicant.save
  end

  def notify_tapo_admin(error)
    msg = 'Error occured while processing registered applicant ' \
          "grant_id: #{grant_id} applicant_id: #{applicant_id} " \
          "error: #{error}"
    AutoMailer.notify_tapo_admin(msg).deliver_now
    Rails.logger.error "Applicant Registration Process error: #{error}"
  end

  def create_trainee_from_applicant
    attrs   = build_trainee_attrs.merge(credentials_attrs)

    trainee = grant.trainees.new(attrs)
    build_job_search_profile(trainee)
    trainee.save
    trainee
  end

  def notify_applicant
    ApplicantMailer.notify_applicant_status(applicant).deliver_now
    Rails.logger.info "Applicant Notification Sent id = #{applicant_id}"
  end

  def notify_password
    ApplicantMailer.notify_applicant_password(applicant, password).deliver_now
    Rails.logger.info "Password is sent to Applicant id = #{applicant_id}"
  end

  def build_job_search_profile(trainee)
    attrs = { account_id: account_id }.merge(job_search_attrs)

    trainee.build_job_search_profile(attrs)
  end

  def job_search_attrs
    return {} unless applicant.valid_address?

    location = applicant.address_city + ',' + applicant.address_state

    { skills: applicant.skills,
      location: location,
      zip: applicant.address_zip,
      distance: 20 }
  end

  def build_trainee_attrs
    attrs = trainee_attrs
    attrs[:tact_three_attributes] = build_tact3_attrs

    if applicant.valid_address?
      attrs[:home_address_attributes] = build_address_attrs
    end
    attrs
  end

  def trainee_attrs
    { first: applicant.first_name,
      last: applicant.last_name,
      email: applicant.email,
      mobile_no: applicant.mobile_phone_no,
      legal_status: applicant.legal_status,
      veteran: applicant.veteran,
      gender: applicant.gender,
      race_id: applicant.race_id,
      dob: applicant.dob }
  end

  def build_address_attrs
    { line1:     applicant.address_line1,
      line2:     applicant.address_line2,
      city:      applicant.address_city,
      state:     applicant.address_state,
      zip:       applicant.address_zip,
      longitude: applicant.longitude,
      latitude:  applicant.latitude
    }
  end

  def build_tact3_attrs
    { education_level: applicant.education_level,
      recent_employer: applicant.last_employer_name,
      job_title:       applicant.last_job_title
    }
  end

  def credentials_attrs
    pwd = password

    { login_id: login_id, password: pwd, password_confirmation: pwd }
  end

  def password
    (applicant.first_name[0..2] + '00000000')[0..7]
  end

  def login_id
    id    = login_id_name
    n = 0
    loop do
      count = Trainee.unscoped.where(login_id: id).count
      break unless count > 0
      n += 1
      id += n.to_s
    end
    id
  end

  def login_id_name
    first = applicant.first_name.delete('^a-zA-Z')
    last  = applicant.last_name.delete('^a-zA-Z')
    first + '_' + last
  end

  def geocode_applicant
    result = GeoServices.perform_search(formatted_address).first
    return unless result

    applicant.longitude = result.longitude
    applicant.latitude = result.latitude
  end

  def formatted_address
    a = applicant
    "#{a.address_line1}, #{a.address_city}, #{a.address_state}, #{a.address_zip}"
  end
end
