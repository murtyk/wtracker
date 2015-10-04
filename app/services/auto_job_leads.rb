# when a grant is set for auto job leads,
#   the trainees in that grant get job leads daily
# first check if trainee has updates job search profile. If not send an email
# find matching jobs for each trainee and send them in an email
# find the most recent (max) job posted date from the leads sent earlier
# only send the jobs with posted date later than above
class AutoJobLeads
  include ActiveSupport
  attr_accessor :statuses

  def initialize
    @statuses = []
  end

  def perform
    return if skip_lead_generation?
    log_info 'AutoJobLeads: performing'

    log_info 'AutoJobLeads: creating missing job search profiles'
    JobSearchProfileJob.new.perform

    send_leads
    log_statuses
    notify
  end

  def log_statuses
    statuses.each do |status|
      status.error_messages.each { |msg| log_info "AutoJobLeads error: #{msg}" }
      lm = "sent leads for account #{status.account_name} - " \
           "grant #{status.grant_name}"
      log_info lm
    end
    log_info "done performing auto leads #{Date.today}"
  end

  def skip_lead_generation?
    if ENV['SKIP_AUTO_LEADS'] == 'YES'
      log_info "AutoJobLeads: skipping auto leads env setting #{Date.today}"
      return true
    end

    log_info "AutoJobLeads: started today: #{Date.today}"

    last_lead_sent_today?
  end

  def last_lead_sent_today?
    asj = AutoSharedJob.last

    return false unless asj

    prev_date = Date.parse(asj.created_at.to_s)

    return false if Date.today > prev_date

    log_info "AutoJobLeads: skipping  prev_date: #{prev_date}"
    true
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
    grant_name = "#{grant.account_name} - #{grant.name}"
    log_info "AutoJobLeads: started leads for #{grant_name}"
    init_trainee_stats
    grant.not_disabled_trainees.each do |trainee|
      perform_action_for_trainee(trainee)
    end
    log_info "AutoJobLeads: completed leads for #{grant_name}"
    build_status(grant)
  end

  def perform_action_for_trainee(trainee)
    action = action_for_trainee(trainee)
    case action
    when :SKIP
    when :OPTED_OUT
      @trainees_opted_out << trainee
    when :SEND_LEADS
      send_leads_to_trainee(trainee)
    when :INCOMPLETE
      @incomplete_profiles << trainee.job_search_profile
    when :SOLICIT_PROFILE
      unless trainee.grant.trainee_applications?
        @job_search_profiles << solicit_profile(trainee)
      end
    end
  end

  def send_leads_to_trainee(trainee)
    leads_sent_count = search_and_send_jobs(trainee)
    @grant_leads_count += leads_sent_count
    @trainee_job_leads << [trainee, leads_sent_count]
    sleep((1 + rand * 10).round)
  rescue StandardError => error
    msg = "AutoJobLeads: Trainee #{trainee.name} " \
          "ID: #{trainee.id} EXCEPTION: #{error}"
    Rails.logger.error msg
  end

  def action_for_trainee(trainee)
    return :SKIP unless trainee.not_placed?
    return :OPTED_OUT if trainee.opted_out_from_auto_leads?
    return :SEND_LEADS if trainee.valid_profile?
    # trainee did not update with skills etc.
    return :INCOMPLETE if trainee.job_search_profile
    return :SOLICIT_PROFILE if trainee.valid_email? # no profile
    @error_messages << "missing or invalid email for trainee #{trainee.name}"
    nil
  end

  def init_trainee_stats
    @job_search_profiles = []
    @incomplete_profiles = []
    @trainee_job_leads   = []
    @trainees_opted_out  = []
    @error_messages = []
    @grant_leads_count = 0
  end

  def build_status(grant)
    GrantJobLeadCount.create(sent_on: Date.today, count: @grant_leads_count)
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
    status.account_name    = grant.account_name
    status.grant_id        = grant.id
    status.grant_name      = grant.name
    status.error_messages  = error_messages
    status
  end

  def search_and_send_jobs(trainee)
    days = determine_days_to_search trainee
    ip = trainee.agent && trainee.agent.info['ip']
    job_board.user_ip(ip) if ip
    jobs = find_matching_jobs(trainee.job_search_profile, days)
    send_jobs(trainee, jobs)
  end

  def send_jobs(trainee, jobs)
    last_posted_date = trainee.auto_shared_jobs.maximum(:date_posted)
    leads_to_be_sent = []
    jobs.each do |job|
      if !last_posted_date || job.date_posted > last_posted_date
        new_lead = trainee.auto_shared_jobs.create_from_job(job, trainee)
        leads_to_be_sent << new_lead
      end
    end
    AutoMailer.send_job_leads(leads_to_be_sent).deliver_now
    leads_to_be_sent.count
  end

  def find_matching_jobs(job_search_profile, days)
    keywords = skills_keywords(job_search_profile)

    # now should have cleaned keywords similar to ['java' 'sdlc' 'project lead']
    # phrases should be escaped

    jobs = find_jobs(job_search_profile, keywords, days)
    return jobs unless jobs.empty?
    return [] if keywords.count < 6

    search_with_split_keywords(job_search_profile, keywords, days)
  end

  def skills_keywords(jsp)
    skills = jsp.skills.downcase
    skills = skills.gsub(' and ', ',')
    skills = skills.gsub(/[^,0-9a-z ]/i, ',')

    keywords = skills.split(',')
    keywords.map { |kw| kw.blank? ? nil : kw.squish }.compact
  end

  def search_with_split_keywords(jsp, keywords, days)
    keywords1, keywords2 = split_keywords(keywords)
    jobs1 = find_jobs(jsp, keywords1, days)
    jobs2 = find_jobs(jsp, keywords2, days)
    jobs = jobs1[0..11] + jobs2[0..12] +
           (jobs1[12..24] || []) + (jobs2[13..24] || [])
    jobs[0..24]
  end

  def split_keywords(kw)
    half = kw.count / 2
    [kw[0..half - 1], kw[half..-1]]
  end

  def find_jobs(jsp, keywords, days)
    sp_by_city, sp_by_zip = build_search_params(jsp, keywords, days)

    search_till_found(sp_by_city, sp_by_zip)

    job_board.jobs
  end

  def search_till_found(sp_by_city, sp_by_zip)
    attempts = 1
    3.times do
      count = search_by_city_zip(sp_by_city, sp_by_zip)
      if count > 0 && attempts > 1
        log_info "AutoJobLeads: JSP id = #{jsp.id} attempts = #{attempts}"
      end
      break if count > 0
      attempts += 1
    end
  end

  def search_by_city_zip(by_city, by_zip)
    count = job_board.search_jobs(by_city)
    return count if count > 0
    job_board.search_jobs(by_zip)
  end

  def build_search_params(jsp, keywords, days)
    search_params = { keywords: keywords, distance: jsp.distance, days: days,
                      search_type: JobBoard::ANY_KEYWORDS_SEARCH }

    by_city = search_params.merge(city: jsp.location)
    by_zip  = search_params.merge(zip: jsp.zip)
    [by_city, by_zip]
  end

  def job_board
    @job_board ||= JobBoard.new
  end

  def solicit_profile(t)
    tp = t.job_search_profile ||
         t.create_job_search_profile(account_id: t.account_id,
                                     key: random_key)

    AutoMailer.solicit_job_search_profile(t).deliver_now
    tp
  end

  def reminder_trainees(params)
    predicate = { job_search_profiles: { skills: nil } }
    predicate = predicate.merge(id: params[:trainee_id]) if params[:trainee_id]

    Trainee.joins(:job_search_profile).where(predicate).order(:first, :last)
  end

  def remind(params, account_id, grant_id)
    Account.current_id = account_id
    Grant.current_id   = grant_id
    trainees = reminder_trainees(params)
    trainees.each { |t| solicit_profile(t) }
  end

  def grants_for_auto_leads
    grants = Grant.unscoped.where('status < 3').load
    grants.map { |g| g if g.auto_job_leads? }.compact
  end

  def determine_days_to_search(trainee)
    trainee.auto_shared_jobs.any? ? 7 : 30
  end

  # send summary status to TAPO admin
  def notify
    AutoMailer.notify_status(statuses).deliver_now
  end

  # send status notification to grant owner
  def notify_grant_status(grant, status)
    AutoMailer.notify_grant_status(grant, status).deliver_now
  end

  def random_key
    SecureRandom.urlsafe_base64(6)
  end

  def log_info(msg)
    Rails.logger.info msg
  end
end
