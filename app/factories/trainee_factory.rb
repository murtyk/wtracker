include UtilitiesHelper
# new, save, update, trainee file
class TraineeFactory
  def self.new_trainee(request_params = nil)
    if request_params
      params = request_params.clone
      params[:dob] = opero_str_to_date(params[:dob]) unless params[:dob].blank?
      clean_addresses(params)
      trainee = Trainee.new(params)
    else
      trainee = Trainee.new
      build_addresses_and_tact3(trainee)
    end
    trainee
  end

  def self.save(trainee)
    saved = trainee.save
    build_addresses_and_tact3(trainee) unless saved
    saved
  end

  def self.update_trainee(all_params)
    params = all_params[:trainee].clone
    clean_addresses(params)

    params[:dob] = opero_str_to_date(params[:dob])
    trainee = Trainee.find(all_params[:id])
    trainee.update_attributes(params)
    trainee
  end

  # in case of applicants grant, a trinee should provide ssn and bd
  #    after signing in for first time
  def self.update_trainee_by_trainee(all_params)
    params   = all_params[:trainee].clone
    trainee  = Trainee.find(all_params[:id])

    trainee.dob        = opero_str_to_date(params[:dob])
    trainee.trainee_id = params[:trainee_id]

    validate_trainee_entered_data(trainee, params)
    return trainee if trainee.errors.any?

    trainee.save
    trainee
  end

  def self.validate_trainee_entered_data(trainee, params)
    ssn = params[:trainee_id].delete('^0-9')
    unless trainee.dob?
      trainee.errors.add(:dob, "Can't be blank. Please enter valid date.")
    end
    trainee.errors.add(:trainee_id, 'Enter 9 digits') unless ssn.size == 9
  end

  # in case of applicants grant, a trainee also can add a file
  def self.add_trainee_file(params, user)
    if user.is_a? Trainee
      trainee  = user
      return [false, 'invalid file type', nil] unless valid_file?(params)
    end

    trainee ||= Trainee.find(params[:trainee_id])
    saved   = false

    begin
      file = Amazon.store_file(params[:file], 'trainee_files')
      trainee_file = trainee.trainee_files.create!(notes: params[:notes],
                                                   file: file, uploaded_by: user.id)
      saved = true
    rescue StandardError => e
      error_message = e.to_s
    end
    [saved, error_message, trainee_file]
  end

  def self.valid_file?(params)
    filename = params[:file].original_filename
    %w(doc docx pdf).include?(filename.split('.')[-1])
  end

  def self.build_addresses_and_tact3(trainee)
    trainee.build_tact_three      unless trainee.tact_three
    trainee.build_home_address    unless trainee.home_address
    trainee.build_mailing_address unless trainee.mailing_address
  end

  def self.valid_address_attributes(a)
    return false if a.blank?
    !a[:line1].blank?
  end

  def self.clean_addresses(params)
    haa = :home_address_attributes
    maa = :mailing_address_attributes
    params.delete(haa)  unless valid_address_attributes params[haa]
    params.delete(maa)  unless valid_address_attributes params[maa]
  end

  def self.create_trainee_from_applicant(applicant)
    grant   = applicant.grant
    attrs   = build_trainee_attrs(applicant)
    attrs   = attrs.merge(credentials_attrs(applicant))

    trainee = grant.trainees.new(attrs)
    build_job_search_profile(applicant, trainee)
    trainee.save
    trainee
  end

  private

  def self.build_job_search_profile(applicant, trainee)
    return unless applicant.valid_address?
    location = applicant.address_city + ',' + applicant.address_state
    trainee.build_job_search_profile(account_id: trainee.account_id,
                                     skills: applicant.skills,
                                     location: location,
                                     zip: applicant.address_zip,
                                     distance: 20)
  end

  def self.build_trainee_attrs(applicant)
    tact_three_attributes = build_tact3_attrs(applicant)
    attrs = { first: applicant.first_name, last: applicant.last_name,
              email: applicant.email, mobile_no: applicant.mobile_phone_no,
              legal_status: applicant.legal_status, veteran: applicant.veteran,
              gender: applicant.gender, race_id: applicant.race_id,
              tact_three_attributes: tact_three_attributes
            }
    geocode_applicant(applicant)

    if applicant.valid_address?
      attrs[:home_address_attributes] = build_address_attrs(applicant)
    end
    attrs
  end

  def self.build_address_attrs(applicant)
    { line1:     applicant.address_line1, line2:     applicant.address_line2,
      city:      applicant.address_city,  state:     applicant.address_state,
      zip:       applicant.address_zip,
      longitude: applicant.longitude,     latitude:  applicant.latitude
    }
  end

  def self.build_tact3_attrs(applicant)
    { education_level: applicant.education_level,
      recent_employer: applicant.last_employer_name,
      job_title:       applicant.last_job_title
    }
  end

  def self.credentials_attrs(applicant)
    pwd = password_for(applicant)

    { login_id: login_id_for(applicant), password: pwd, password_confirmation: pwd }
  end

  def self.password_for(ap)
    pwd = ap.email.split('@')[0]
    return pwd if pwd.length > 7
    (pwd + '12345678')[0..7]
  end

  def self.login_id_for(ap)
    first = ap.first_name.delete('^a-zA-Z')
    last  = ap.last_name.delete('^a-zA-Z')
    id    = first + '_' + last
    n = 0
    loop do
      t = Trainee.unscoped.where(login_id: id).first
      break unless t
      n += 1
      id += n.to_s
    end
    id
  end

  def valid_file_suffix(filename)
    %w(doc docs pdf).include? filename.split('.')[-1]
  end

  def self.geocode_applicant(a)
    addr = "#{a.address_line1}, #{a.address_city}, #{a.address_state}, #{a.address_zip}"
    result = Geocoder.search(addr).first
    if result
      a.longitude = result.longitude
      a.latitude = result.latitude
    end
  end
end
