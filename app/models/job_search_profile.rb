# trainee enters job search parameters
class JobSearchProfile < ActiveRecord::Base
  attr_accessible :account_id, :trainee_id, :skills, :location, :distance, :zip, :key,
                  :opted_out, :opt_out_reason_code, :opt_out_reason,
                  :company_name, :start_date, :title, :salary
  belongs_to :account

  validate :validate_search_params, :validate_opt_out_params
  before_save :cb_before_save

  OPT_OUT_REASONS = { 1 => 'Found Employment', 2 => 'No longer looking for work',
                      3 => 'Moved out of the area' }

  def trainee
    Trainee.unscoped.find(trainee_id)
  end
  delegate :job_leads_count,
           :not_viewed_job_leads_count,
           :viewed_job_leads_count,
           :applied_job_leads_count,
           :not_interested_job_leads_count, to: :trainee

  delegate :name, to: :trainee

  def valid_profile?
    !skills.blank? && !location.blank? && distance
  end

  def valid_key?(param_key)
    param_key == key
  end

  def opted_out_date
    updated_at.to_date.to_s if opted_out
  end

  def opted_out_reason
    OPT_OUT_REASONS[opt_out_reason_code]
  end

  def opted_out_reason_desc
    opt_out_reason if opt_out_reason_code == 2
  end

  def opted_out_new_employer
    company_name if  opt_out_reason_code == 1
  end

  def opted_out_title
    title if  opt_out_reason_code == 1
  end

  def opted_out_start_date
    start_date if  opt_out_reason_code == 1
  end

  def opted_out_confirmation_message
    grant = Grant.unscoped.find(trainee.grant_id)
    return grant.optout_message_one.content if opt_out_reason_code == 1
    return grant.optout_message_two.content if opt_out_reason_code == 2
    grant.optout_message_three.content
  end

  def auto_shared_jobs(show_all = true, status = 'Not Viewed')
    jobs = jobs_with_status(status)

    jobs = jobs.where('created_at >= :sd',
                      sd: recent_job_lead.created_at.to_date) if !show_all &&
                                                                 recent_job_lead
    jobs.order(date_posted: :desc).to_a
  end

  def jobs_with_status(status)
    status_codes = AutoSharedJob.status_codes(status)
    trainee.auto_shared_jobs.where(status: status_codes)
  end

  def recent_job_lead
    trainee.auto_shared_jobs.last
  end

  def validate_search_params
    return true if skills.nil? && location.nil? && zip.nil? && distance.nil?
    valid  = validate_skills
    valid &= validate_distance
    valid &= validate_location

    return false unless valid

    # we need to resolve simplyhired issues
    # check if this results in any jobs
    # can_find_jobs?
    valid
  end

  def location_error_messages
    msgs = [errors[:location][0], errors[:zip][0]].compact
    msgs.map { |m| "<br><span style='color: #B94A48'>#{m}</span>" }.join('').html_safe
  end

  private

  def can_find_jobs?
    ajl        = AutoJobLeads.new
    finds_jobs = ajl.find_matching_jobs(self, 30).any?

    msg = 'Entered skills(key words) are not finding any jobs.' \
          'Please refine search keywords(skills).' \
          'Suggestion: check spellings and reduce size'
    errors.add(:skills, msg) unless finds_jobs
    finds_jobs
  end

  def validate_location
    if zip.blank? && location.blank?
      errors.add(:location, "can't be blank")
      return false
    end

    return validate_zip(zip) unless zip.blank?

    city = city_from_location
    !city.blank?
  end

  def city_from_location
    state_code = location.split(',')[1]
    return nil unless valid_state_code(state_code)

    city = GeoServices.findcity(location, '')
    errors.add(:location, 'not found') unless city
    city
  end

  def validate_zip(zip)
    city = GeoServices.findcity('', zip)
    errors.add(:zip, 'location not found for this zip code') unless city
    !city.blank?
  end

  def valid_state_code(code)
    errors.add(:location, 'please enter state code. ex: Edison,NJ') if code.blank?
    return false if code.blank?

    valid_code = State.valid_state_code?(code)
    errors.add(:location, 'state code missing or invalid') unless valid_code
    valid_code
  end

  def validate_skills
    size = skills.to_s.size
    return true if size > 0 && size < 421
    errors.add(:skills, "can't be blank") if skills.blank?
    errors.add(:skills, "size(#{size}) exceeds 420 characters.") if size > 420
    false
  end

  def validate_distance
    return true unless distance.blank?
    errors.add(:distance, "can't be blank")
    false
  end

  def validate_opt_out_params
    valid = true
    if opt_out_reason_code == 1
      [:company_name, :title, :start_date].each do |attr|
        if send(attr).blank?
          errors.add(attr, "can't be blank")
          valid = false
        end
      end
    end
    if opt_out_reason && opt_out_reason.length > 254
      errors.add(:opt_out_reason, 'please limit to 255 characters')
      valid = false
    end
    valid
  end

  def cb_before_save
    return true if zip.blank? && location.blank?
    if zip.blank?
      city = GeoServices.findcity(location, '')
    else
      city = GeoServices.findcity('', zip)
    end
    self.location = "#{city.name},#{city.state_code}"
  end
end
