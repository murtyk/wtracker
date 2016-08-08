include UtilitiesHelper
# to build and update applicant
class ApplicantFactory
  def self.new_applicant(grant, params)
    applicant = grant.applicants.new(params_opero_dates(params))

    applicant.navigator_id = navigator_id(applicant)
    applicant
  end

  def self.create(grant, _request, params)
    applicant = new_applicant(grant, params)

    Applicant.transaction do
      applicant.save
      return applicant if applicant.errors.any?
      ApplicantRegistration.new(applicant.id).delay.process
    end
    applicant
  end

  def self.update(id, params)
    return reapply(id, params) if params[:reapply_key]

    applicant = Applicant.find id

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

    return unless trainee.errors.any?

    copy_error_messages(applicant, trainee)
    fail ActiveRecord::Rollback, 'Inform TAPO Support Staff'
  end

  def self.parse_params(params)
    a_params  = params.clone
    t_params  = a_params.delete(:trainee)
    t_params.delete(:id) if t_params
    [a_params, t_params]
  end

  def self.reapply(id, params)
    applicant = Applicant.find id
    process_reapply(applicant, params_opero_dates(params))
  end

  def self.process_reapply(applicant, params)
    Applicant.transaction do
      applicant.update_attributes(params)
      return applicant if applicant.errors.any?
      applicant.navigator_id = navigator_id(applicant)
      applicant.save

      ApplicantRegistration.new(applicant.id).delay.process

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

    log_navigator_not_found(applicant) unless user

    user && user.id
  end

  def self.log_navigator_not_found(ap)
    msg = "navigator not found for #{ap.name} county_id #{ap.county_id}"
    Rails.logger.error(msg)
  end

  # def self.capture_applicant_location(request, applicant)
  #   location = request.location
  #   if location
  #     applicant.create_agent(info: request.location.data)
  #   else
  #     error = "request.location returned null ip: #{request.remote_ip}"
  #     applicant.create_agent(info: { error:  error })
  #   end
  # end

  def self.copy_error_messages(ap, t)
    message = t.errors.full_messages[0]
    ap.errors.add(:trainee_id, message)
    t.errors.each { |f, m| ap.errors.add(f, m) if ap.respond_to?(f) }
  end

  def self.create_reapply(params, grant)
    params ||= {}
    ap = Applicant.find_by('email ilike ?', params[:email])
    ra = ApplicantReapply.new(email: params[:email])

    validate_reapply(grant, ap, ra)

    return ra if ra.errors.any?

    ra = ap.applicant_reapplies.create(key: random_key)
    ApplicantMailer.applicant_reapply(ap).deliver_now
    ra
  end

  def self.validate_reapply(grant, ap, ra)
    ra.errors.add(:base, grant.reapply_email_not_found_message) unless ap
    return unless ap && ap.accepted?
    ra.errors.add(:base, grant.reapply_already_accepted_message)
  end

  def self.random_key
    SecureRandom.urlsafe_base64(6)
  end

  def self.params_opero_dates(params)
    a_params  = params.clone
    a_params[:last_employed_on] = opero_str_to_date(a_params[:last_employed_on])
    a_params[:dob] = opero_str_to_date(a_params[:dob])
    a_params
  end

  def self.navigators
    nav_counts = Applicant.group(:navigator_id).count
    nav_ids = nav_counts.map{|id, count| id}.compact
    navs = User.where(id: nav_ids).order(:first, :last)
    navs.map do |nav|
      OpenStruct.new(id: nav.id, to_label: nav.name + "(#{nav_counts[nav.id]})")
    end
  end

  def self.assign_navigator(params)
    count = Applicant.where(navigator_id: params[:from_nav_id]).count
    Applicant
      .where(navigator_id: params[:from_nav_id])
      .update_all(navigator_id: params[:to_nav_id])
    count
  end
end
