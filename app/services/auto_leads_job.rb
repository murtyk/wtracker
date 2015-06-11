# when a grant is set for auto job leads, the trainees in that grant get job leads daily
# first check if trainee has updates job search profile. If not send an email
# find matching jobs for each trainee and send them in an email
# find the most recent (max) job posted date from the leads sent earlier
# only send the jobs with posted date later than above
class AutoLeadsJob
  include ActiveSupport

  WORKERS_COUNT = ENV['TAPO_WORKERS_COUNT']

  attr_accessor :error_messages

  def perform
    return if skip_lead_generation?
    Rails.logger.info 'AutoLeadsJob: performing'
    lqf = LeadsQueueFactory.new
    lqf.generate
    @error_messages = lqf.error_messages
    spin_tapo_workers
    queue_leads_job_on_workers
    Rails.logger.info 'AutoLeadsJob: done'
  end

  def skip_lead_generation?
    if ENV['SKIP_AUTO_LEADS'] == 'YES'
      Rails.logger.info "AutoLeadsJob: skipping auto leads env setting #{Date.today}"
      return true
    end

    Rails.logger.info "AutoLeadsJob: started today: #{Date.today}"

    last_lead_sent_today?
  end

  def last_lead_sent_today?
    asj = AutoSharedJob.last

    return false unless asj

    prev_date = Date.parse(asj.created_at.to_s)

    return false if Date.today > prev_date

    Rails.logger.info "AutoLeadsJob: skipping  prev_date: #{prev_date}"
    true
  end

  def spin_tapo_workers
    return if Rails.env.development? || Rails.env.test?
    HerokuControl.auto_leads_workers_up
  end

  def queue_leads_job_on_workers
    1.upto(WORKERS_COUNT.to_i) do |n|
      tw = TapoWorker.new(n)
      tw.queue_job('TraineeLeadsJob')
    end
  end
end
