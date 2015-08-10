include UtilitiesHelper
# to build and update applicant
class ApplicantFactory
  def self.new_applicant(grant, params)
    applicant = grant.applicants.new(params)
    applicant.last_employed_on = opero_str_to_date(params[:last_employed_on])
    applicant.dob = opero_str_to_date(params[:dob])

    applicant.navigator_id = navigator_id(applicant)
    applicant
  end

  def self.create(grant, _request, params)
    applicant = new_applicant(grant, params)

    Applicant.transaction do
      applicant.save
      return applicant if applicant.errors.any?
      # skip location capture. it is causing time out errors.
      # capture_applicant_location(request, applicant)


      # process_applicant(applicant)
      ApplicantRegistration.new(applicant.id).delay.process
    end
    applicant
  end

  def self.update(params)
    return reapply(params) if params[:applicant][:reapply_key]

    applicant = Applicant.find params[:id]

    a_params, t_params = parse_params(params)

    Applicant.transaction do
      update_applicant(applicant, a_params)
      update_trainee(applicant, t_params)
    end
    applicant
  end

  def self.update_applicant(applicant, a_params)
    return unless a_params.any?
    applicant.attributes = a_params
    applicant.save(validate: false)
  end

  def self.update_trainee(applicant, t_params)
    trainee = applicant.trainee
    trainee.update_attributes(t_params) if t_params
    if trainee.errors.any?
      copy_error_messages(applicant, trainee)
      fail ActiveRecord::Rollback, 'Inform TAPO Support Staff'
    end
  end

  def self.parse_params(params)
    a_params  = params[:applicant].clone
    t_params  = a_params.delete(:trainee)
    t_params.delete(:id) if t_params
    [a_params, t_params]
  end

  def self.reapply(params)
    applicant = Applicant.find params[:id]
    a_params  = params[:applicant]
    a_params[:last_employed_on] = opero_str_to_date(a_params[:last_employed_on])
    a_params[:dob] = opero_str_to_date(a_params[:dob])

    Applicant.transaction do
      applicant.update_attributes(a_params)
      return applicant if applicant.errors.any?
      applicant.navigator_id = navigator_id(applicant)
      applicant.save

      ApplicantRegistration.new(applicant.id).delay.process
      # process_applicant(applicant)

      applicant.void_reapplication
    end
    applicant
  end

  def self.navigator_id(applicant)
    return nil if applicant.county_id.blank?
    users = applicant.grant.navigators
    user  = users.joins(:user_counties)
            .where(user_counties: { county_id: applicant.county_id })
            .first
    unless user
      msg = "navigator not found for #{applicant.first_name} #{applicant.last_name}" \
            " county_id #{applicant.county_id}"
      Rails.logger.error(msg)
    end
    user && user.id
  end

  # def self.process_applicant(applicant)
  #   if applicant.accepted?
  #     trainee = TraineeFactory.create_trainee_from_applicant(applicant)
  #     if trainee.errors.any?
  #       copy_error_messages(applicant, trainee)
  #       fail ActiveRecord::Rollback, 'Inform Grant Staff'
  #     end
  #     applicant.trainee_id = trainee.id
  #     applicant.save
  #   end
  #   notify_applicant(applicant)
  # end

  # def self.notify_applicant(applicant)
  #   if applicant.accepted? || applicant.declined?
  #     AutoMailer.notify_applicant_status(applicant).deliver_now
  #   end
  # end

  def self.capture_applicant_location(request, applicant)
    location = request.location
    if location
      applicant.create_agent(info: request.location.data)
    else
      error = "request.location returned null ip: #{request.remote_ip}"
      applicant.create_agent(info: { error:  error })
    end
  end

  def self.copy_error_messages(applicant, trainee)
    message = trainee.errors.full_messages[0]
    applicant.errors.add(:trainee_id, message)
    trainee.errors.each do |f, m|
      applicant.errors.add(f, m) if applicant.respond_to?(f)
    end
  end

  def self.create_reapply(params, grant)
    params ||= {}
    ap = Applicant.find_by('email ilike ?', params[:email])
    ra = ApplicantReapply.new(email: params[:email])

    validate_reapply(grant, ap, ra)

    # ra.errors.add(:base, grant.reapply_email_not_found_message) unless ap
    # ra.errors.add(:base, grant.reapply_already_accepted_message) if ap && ap.accepted?

    return ra if ra.errors.any?

    ra = ap.applicant_reapplies.create(key: random_key)
    AutoMailer.applicant_reapply(ap).deliver_now
    ra
  end

  def self.validate_reapply(grant, ap, ra)
    ra.errors.add(:base, grant.reapply_email_not_found_message) unless ap
    ra.errors.add(:base, grant.reapply_already_accepted_message) if ap && ap.accepted?
  end

  def self.random_key
    SecureRandom.urlsafe_base64(6)
  end
end
