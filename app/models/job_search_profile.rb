# frozen_string_literal: true

# trainee enters job search parameters
class JobSearchProfile < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_skills,
                  against: :skills,
                  using: { tsearch: { any_word: true } }

  belongs_to :account, optional: true
  belongs_to :trainee, optional: true

  validate :validate_search_params, :validate_opt_out_params
  before_save :cb_before_save

  OPT_OUT_REASONS = { 1 => 'Found Employment',
                      2 => 'No longer looking for work',
                      3 => 'Moved out of the area' }.freeze

  def self.ransackable_attributes(auth_object = nil)
    ["account_id", "company_name", "created_at", "distance", "id", "key", "location", "opt_out_reason", "opt_out_reason_code", "opted_out", "salary", "skills", "start_date", "title", "trainee_id", "updated_at", "zip"]
  end

  def trainee
    Trainee.unscoped.find(trainee_id)
  end
  delegate :job_leads_count,
           :not_viewed_job_leads_count,
           :viewed_job_leads_count,
           :applied_job_leads_count,
           :job_lead_counts_by_status,
           :not_interested_job_leads_count, to: :trainee

  delegate :name, to: :trainee

  def valid_profile?
    !trimmed_skills.blank? && !location.blank? && distance
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
    company_name if opt_out_reason_code == 1
  end

  def opted_out_title
    title if opt_out_reason_code == 1
  end

  def opted_out_start_date
    start_date if opt_out_reason_code == 1
  end

  def opted_out_confirmation_message
    grant = Grant.unscoped.find(trainee.grant_id)
    return grant.optout_message_one.content if opt_out_reason_code == 1
    return grant.optout_message_two.content if opt_out_reason_code == 2

    grant.optout_message_three.content
  end

  def auto_shared_jobs(show_all = true, status = nil)
    jobs = jobs_with_status(status)

    return jobs unless !show_all && recent_job_lead

    jobs.where('created_at >= :sd', sd: recent_job_lead.created_at.to_date)
  end

  def jobs_with_status(status)
    return trainee.auto_shared_jobs.order(date_posted: :desc) unless status

    status_codes = AutoSharedJob.status_codes(status)
    trainee
      .auto_shared_jobs
      .where(status: status_codes)
      .order(date_posted: :desc)
  end

  def recent_job_lead
    trainee.auto_shared_jobs.last
  end

  def validate_search_params
    return true if all_params_blank?

    validate_skills && validate_distance && validate_location
  end

  def all_params_blank?
    skills.nil? && location.nil? && zip.nil? && distance.nil?
  end

  def location_error_messages
    msgs = [errors[:location][0], errors[:zip][0]].compact
    msgs.map { |m| "<br><span style='color: #B94A48'>#{m}</span>" }
        .join('')
        .html_safe
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

    unless zip.blank?
      zip_valid = validate_zip(zip)
      return true if zip_valid
    end

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
    return false unless zip
    return false unless zip.to_s.delete('^0-9').size > 4

    city = City.find_by(zip: zip) || GeoServices.findcity('', zip)
    # errors.add(:zip, 'location not found for this zip code') unless city
    !city.blank?
  end

  def valid_state_code(code)
    if code.blank?
      errors.add(:location, 'please enter state code. ex: Edison,NJ')
      return false
    end

    valid_code = State.valid_state_code?(code)
    errors.add(:location, 'state code missing or invalid') unless valid_code
    valid_code
  end

  def validate_skills
    size = skills.to_s.size
    return true if size.positive? && size < 421

    errors.add(:skills, "can't be blank") if skills.blank? || trimmed_skills.blank?
    errors.add(:skills, "size(#{size}) exceeds 420 characters.") if size > 420
    false
  end

  def trimmed_skills
    skills
      .to_s
      .downcase
      .gsub(' and ', ',')
      .gsub(/[^,0-9a-z ]/i, ',')
      .split(',')
      .map { |kw| kw.blank? ? nil : kw.squish }
      .compact
      .join(',')
  end

  def validate_distance
    return true unless distance.blank?

    errors.add(:distance, "can't be blank")
    false
  end

  def validate_opt_out_params
    validate_optout_data
    validate_optout_reason_text
    errors.empty?
  end

  def validate_optout_data
    return true unless opt_out_reason_code == 1

    %i[company_name title start_date].each do |attr|
      errors.add(attr, "can't be blank") if send(attr).blank?
    end
  end

  def validate_optout_reason_text
    return true unless opt_out_reason && opt_out_reason.length > 254

    errors.add(:opt_out_reason, 'please limit to 255 characters')
  end

  def cb_before_save
    return true if zip.blank? && location.blank?

    city = find_city
    unless city
      errors.add(:zip,
                 "city not found for zip:#{zip} location: #{location} trainee_id: #{trainee_id}")
      return false
    end
    self.location = "#{city.name},#{city.state_code}"
  end

  def find_city
    return GeoServices.findcity(location, '') if zip.blank?

    City.find_by(zip: zip) ||
      GeoServices.findcity('', zip) ||
      GeoServices.findcity(location, '')
  end
end
