# when a grant is set for auto job leads, the trainees in that grant get job leads daily
# first check if trainee has updates job search profile. If not send an email
# find matching jobs for each trainee and send them in an email
# find the most recent (max) job posted date from the jobs leads sent earlier
# only send the jobs with posted date later than above
class AutoJobLeads
  include ActiveSupport
  attr_accessor :statuses

  def initialize
    @statuses = []
  end

  def perform
    if ENV['SKIP_AUTO_LEADS'] == 'YES'
      Rails.logger.info "AutoJobLeads: skipping auto leads env setting #{Date.today}"
      return
    else
      Rails.logger.info "AutoJobLeads: started performing #{Date.today}"
    end

    asj = AutoSharedJob.last
    if asj
      prev_date = Date.parse(asj.created_at.to_s)
      unless Date.today > prev_date
        Rails.logger.info "AutoJobLeads: skipping  prev_date: #{prev_date}"
        return
      end
    end

    Rails.logger.info 'AutoJobLeads: performing'

    use_job_leads_email
    send_leads
    statuses.each do |status|
      status.error_messages.each { |msg| Rails.logger.info "AutoJobLeads error: #{msg}" }
      lm = "sent leads for account #{status.account_name} - grant #{status.grant_name}"
      Rails.logger.info lm
    end
    Rails.logger.info "done performing auto leads #{Date.today}"
    notify
    use_standard_email
  end

  def send_leads
    grants_for_auto_leads.each do |grant|
      Account.current_id = grant.account_id
      Grant.current_id   = grant.id
      if grant.email_messages_defined?
        status = send_leads_for_grant_trainees(grant)
        @statuses << status
        notify_grant_status(grant, status)
      else
        @statuses << new_status(grant, ['email message(s) missing'])
      end
    end
  end

  def send_leads_for_grant_trainees(grant)
    init_trainee_stats
    Trainee.unscoped.where(grant_id: grant.id).each do |trainee|
      if trainee.valid_profile? && trainee.opted_out_from_auto_leads?
        @trainees_opted_out << trainee
      elsif trainee.valid_profile?
        leads_sent_count = search_and_send_jobs(trainee)
        @trainee_job_leads << [trainee, leads_sent_count]
        sleep 1
      elsif trainee.job_search_profile # trainee did not update with skills etc.
        @incomplete_profiles << trainee.job_search_profile
      elsif trainee.valid_email? # no profile
        @job_search_profiles << solicit_profile(trainee) unless grant.trainee_applications?
      else # no profile and email missing
        @error_messages << "missing or invalid email for trainee #{trainee.name}"
      end
    end
    build_status(grant)
  end

  def init_trainee_stats
    @job_search_profiles = []
    @incomplete_profiles = []
    @trainee_job_leads   = []
    @trainees_opted_out  = []
    @error_messages = []
  end

  def build_status(grant)
    status = new_status(grant, @error_messages)

    status.job_search_profiles = @job_search_profiles.compact
    status.incomplete_profiles = @incomplete_profiles
    status.trainees_opted_out  = @trainees_opted_out
    status.trainee_job_leads   = @trainee_job_leads
    status
  end

  def new_status(grant, error_messages)
    status                 = OpenStruct.new
    status.account_id      = grant.account_id
    status.account_name    = grant.account.name
    status.grant_id        = grant.id
    status.grant_name      = grant.name
    status.error_messages  = error_messages
    status
  end

  def search_and_send_jobs(trainee)
    days = determine_days_to_search trainee
    jobs = find_matching_jobs(trainee.job_search_profile, days)
    send_jobs(trainee, jobs)
  end

  def send_jobs(trainee, jobs)
    last_posted_date = trainee.auto_shared_jobs.maximum(:date_posted)
    leads_to_be_sent = []
    jobs.each do |job|
      if !last_posted_date || job.date_posted > last_posted_date
        leads_to_be_sent << trainee.auto_shared_jobs.create_from_job(job, trainee)
      end
    end
    AutoMailer.send_job_leads(leads_to_be_sent).deliver_now
    leads_to_be_sent.count
  end

  def find_matching_jobs(job_search_profile, days)
    skills = job_search_profile.skills.downcase
    skills = skills.gsub(' and ', ',')
    skills = skills.gsub(/[^,0-9a-z ]/i, ',')

    keywords = skills.split(',')
    keywords = keywords.map { |kw| kw.blank? ? nil : kw.squish }.compact

    # now should have cleaned keywords similar to ['java' 'sdlc' 'project lead']
    # phrases should be escaped

    jobs = find_jobs(job_search_profile, keywords, days)
    return jobs unless jobs.empty?
    return [] if keywords.count < 6
    # split keyword
    half = keywords.count / 2
    keywords1 = keywords[0..half - 1]
    keywords2 = keywords[half..-1]
    jobs1 = find_jobs(job_search_profile, keywords1, days)
    jobs2 = find_jobs(job_search_profile, keywords2, days)
    jobs = jobs1[0..11] + jobs2[0..12] + (jobs1[12..24] || []) + (jobs2[13..24] || [])
    jobs[0..24]
  end

  def find_jobs(jsp, keywords, days)
    search_params = { keywords: keywords, distance: jsp.distance, days: days,
                      search_type: JobBoard::ANY_KEYWORDS_SEARCH }

    search_params_by_city = search_params.merge(city: jsp.location)
    search_params_by_zip  = search_params.merge(zip: jsp.zip)

    jobs = []
    attempts = 1
    3.times do
      count = job_board.search_jobs(search_params_by_city)
      count = job_board.search_jobs(search_params_by_zip) if count == 0
      if count > 0 && attempts > 1
        Rails.logger.info "AutoJobLeads: JSP id = #{jsp.id} attempts = #{attempts}"
      end
      break unless jobs.empty?
      attempts += 1
    end
    job_board.jobs
  end

  def job_board
    @job_board ||= JobBoard.new
  end

  def solicit_profile(t)
    tp = t.job_search_profile || t.create_job_search_profile(account_id: t.account_id,
                                                             key: random_key)

    AutoMailer.solicit_job_search_profile(t).deliver_now
    tp
  end

  def reminder_trainees(params)
    predicate = { job_search_profiles: { skills: nil } }
    predicate = predicate.merge(id: params[:trainee_id]) if params[:trainee_id]

    Trainee.includes(:job_search_profile).where(predicate).order(:first, :last)
  end

  def remind(params, account_id, grant_id)
    Account.current_id = account_id
    Grant.current_id   = grant_id
    trainees = reminder_trainees(params)
    use_job_leads_email
    trainees.each { |t| solicit_profile(t) }
    use_standard_email
  end

  def grants_for_auto_leads
    grants = Grant.unscoped.where('status < 3').load
    grants.map { |g| g if g.auto_job_leads? }.compact
  end

  def determine_days_to_search(trainee)
    trainee.auto_shared_jobs.any? ? 7 : 30
  end

  def notify
    AutoMailer.notify_status(statuses).deliver_now
  end

  def notify_grant_status(grant, status)
    AutoMailer.notify_grant_status(grant, status).deliver_now
  end

  def random_key
    SecureRandom.urlsafe_base64(6)
  end

  # KORADA. design is not goot. AutoMailer should encapsulate calling these methods
  delegate :use_job_leads_email, :use_standard_email, to: EmailSettings
end
