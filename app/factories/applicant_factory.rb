include UtilitiesHelper
# to build and update applicant
class ApplicantFactory
  def self.create(grant, request, params)
    params[:last_employed_on] = opero_str_to_date(params[:last_employed_on])
    applicant = grant.applicants.new(params)

    applicant.navigator_id = navigator_id(applicant)

    Applicant.transaction do
      applicant.save
      return applicant if applicant.errors.any?
      capture_applicant_location(request, applicant)
      process_applicant(applicant)
    end
    applicant
  end

  def self.update(params)
    return reapply(params) if params[:applicant][:reapply_key]

    applicant = Applicant.find params[:id]
    a_params  = params[:applicant]
    fs_id     = a_params.delete(:funding_source_id).to_i

    Applicant.transaction do
      applicant.update_attributes(a_params) if a_params.any?
      trainee = applicant.trainee
      trainee.update_attributes(funding_source_id: fs_id) if fs_id > 0
      if trainee.errors.any?
        trainee.errors.each do |f, m|
          applicant.errors.add(f, m) if applicant.respond_to?(f)
        end
        fail ActiveRecord::Rollback, 'Inform TAPO Support Staff'
      end
    end
    applicant
  end

  def self.reapply(params)
    applicant = Applicant.find params[:id]
    a_params  = params[:applicant]
    a_params[:last_employed_on] = opero_str_to_date(a_params[:last_employed_on])

    Applicant.transaction do
      applicant.update_attributes(a_params)
      return applicant if applicant.errors.any?
      applicant.navigator_id = navigator_id(applicant)

      process_applicant(applicant)

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

  def self.process_applicant(applicant)
    if applicant.accepted?
      trainee, _pwd = TraineeFactory.create_trainee_from_applicant(applicant)
      if trainee.errors.any?
        copy_error_messages(applicant, trainee)
        fail ActiveRecord::Rollback, 'Inform Grant Staff'
      end
      applicant.trainee_id = trainee.id
      applicant.save
    end
    notify_applicant(applicant)
  end

  def self.notify_applicant(applicant)
    if applicant.accepted? || applicant.declined?
      AutoMailer.notify_applicant_status(applicant).deliver
    end
  end

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
    message = trainee.errors.first[0].to_s + ' ' + trainee.errors.first[1]
    applicant.errors.add(:trainee_id, message)
    trainee.errors.each do |f, m|
      applicant.errors.add(f, m) if applicant.respond_to?(f)
    end
  end

  def self.create_reapply(applicant)
    applicant.applicant_reapplies.create(key: random_key)
    AutoMailer.applicant_reapply(applicant).deliver
  end

  def self.random_key
    SecureRandom.urlsafe_base64(6)
  end
end
