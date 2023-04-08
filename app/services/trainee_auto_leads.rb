# frozen_string_literal: true

# searches and sends job leads for one trainee
class TraineeAutoLeads
  attr_reader :trainee, :jsp

  class << self
    def perform(account_id, grant_id, trainee_id)
      Account.current_id = account_id
      Grant.current_id = grant_id
      TraineeAutoLeads.new(trainee_id).perform
    end
  end

  def initialize(trainee_id)
    @trainee = Trainee.find(trainee_id)
    @jsp = trainee.job_search_profile
  end

  def perform
    take_a_nap
    init_ip
    send_jobs(find_matching_jobs)
  rescue StandardError => e
    msg = "AutoJobLeads: Trainee #{trainee.name} " \
          "ID: #{trainee.id} EXCEPTION: #{e}\n" + e.backtrace.join("\n")
    Rails.logger.error msg
  end

  def init_ip
    ip = trainee.agent && trainee.agent.info['ip']
    job_board.user_ip(ip) if ip
  end

  def take_a_nap
    sleep(rand(1..3))
  end

  # rubocop:disable Metrics/AbcSize
  def send_jobs(jobs)
    last_posted_date = most_recent_posted_date
    leads_to_be_sent = []

    jobs.each do |job|
      if !last_posted_date || job.date_posted > last_posted_date
        new_lead = trainee.auto_shared_jobs.create_from_job(job, trainee)
        leads_to_be_sent << new_lead
      end
    end

    return if leads_to_be_sent.none?

    Rails.cache.write(cache_key, leads_to_be_sent.count)
    AutoMailer.send_job_leads(leads_to_be_sent).deliver_now
  end

  def most_recent_posted_date
    trainee.auto_shared_jobs.maximum(:date_posted)
  end

  def find_matching_jobs
    jobs = find_jobs(keywords)

    return jobs if jobs.any?
    return [] if keywords.count < 6

    search_with_split_keywords
  end

  def keywords
    @keywords ||= begin
      skills = jsp.skills.downcase
      skills = skills.gsub(' and ', ',')
      skills = skills.gsub(/[^,0-9a-z ]/i, ',')

      keywords = skills.split(',')
      keywords.map { |kw| kw.blank? ? nil : kw.squish }.compact
    end
  end

  def search_with_split_keywords
    kw1, kw2 = split_keyword

    jobs1 = find_jobs(kw1)
    jobs2 = find_jobs(kw2)

    jobs = jobs1[0..11] + jobs2[0..12] +
           (jobs1[12..24] || []) + (jobs2[13..24] || [])
    jobs[0..24]
  end

  def split_keyword
    half = keywords.count / 2
    [keywords[0..half - 1], keywords[half..-1]]
  end

  def find_jobs(keywords)
    sp_by_city, sp_by_zip = build_search_params(keywords)

    search_till_found(sp_by_city, sp_by_zip)

    job_board.jobs
  end

  def search_till_found(sp_by_city, sp_by_zip)
    attempts = 1
    3.times do
      count = search_by_city_zip(sp_by_city, sp_by_zip)
      if count.positive? && attempts > 1
        log_info "AutoJobLeads: JSP id = #{jsp.id} attempts = #{attempts}"
      end
      break if count.positive?

      attempts += 1
    end
  end

  def search_by_city_zip(by_city, by_zip)
    count = job_board.search_jobs(by_city)
    return count if count.positive?

    job_board.search_jobs(by_zip)
  end

  def build_search_params(keywords)
    days = determine_days_to_search

    search_params = { keywords: keywords, distance: jsp.distance, days: days,
                      search_type: JobBoard::ANY_KEYWORDS_SEARCH }

    by_city = search_params.merge(city: jsp.location)
    by_zip  = search_params.merge(zip: jsp.zip)
    [by_city, by_zip]
  end

  def determine_days_to_search
    trainee.auto_shared_jobs.any? ? 7 : 30
  end

  def job_board
    @job_board ||= JobBoard.new
  end

  def cache_key
    "g#{trainee.grant_id}_#{trainee.id}"
  end
end
