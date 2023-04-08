# frozen_string_literal: true

# captures search criteria and results
# searched jobs are not persisted
class JobSearch < ApplicationRecord
  JOBSEARCH_DAYS     = { 'Last 24 hours' => 1,
                         'Last 7 days' => 7,
                         'Last 14 days' => 14,
                         'Last 30 days' => 30,
                         'Anytime' => 0 }.freeze
  JOBSEARCH_DISTANCE = { 5 => 5, 10 => 10, 15 => 15, 25 => 25, 50 => 50,
                         'Exact Location' => 0 }.freeze
  JOBS_SLICE_SIZE = 100

  default_scope { where(account_id: Account.current_id) }

  belongs_to :user
  belongs_to :account
  belongs_to :klass_title

  attr_accessor :college_id
  attr_reader :analyzer, :jobs, :jobs_count, :page, :pages

  after_initialize :init

  def init
    self.days     ||= 7
    self.distance ||= 10
  end

  def to_label
    "#{location} - #{keywords} - #{distance} miles"
  end

  def parts
    location.split(',')
  end

  def zip
    parts.count == 1 ? parts[0].squish : nil
  end

  def city
    parts.count > 1 ? parts[0].squish : nil
  end

  def state
    parts.count > 1 ? parts[1].squish.upcase : nil
  end

  def analyzer(user, request_ip = nil)
    @analyzer ||= JobsAnalyzer.new(self, request_ip, user)
  end

  def search_criteria
    days_suffix = days.positive? ? "in last #{days} days" : 'anytime'
    "#{keywords} - #{location} - #{distance} miles - posted " + days_suffix
  end

  def new_search
    JobSearch.new(location: location,
                  keywords: keywords,
                  days: days,
                  in_state: in_state,
                  distance: distance)
  end

  def perform_search(ip, page = 1)
    @page = page
    @job_search_service = JobSearchServices.new(self, ip)
    @job_search_service.perform_search(page)
  end

  def jobs
    @job_search_service.jobs
  end

  def pages
    (jobs_count + 24) / 25
  end

  def jobs_count
    @job_search_service.jobs_count
  end

  def first_page?
    page == 1
  end

  def last_page?
    page == pages
  end

  def page_position
    return 'first' if page == 1

    page == pages ? 'last' : 'middle'
  end

  def prev_page
    first_page? ? 1 : page - 1
  end

  def next_page
    last_page? ? pages : page + 1
  end

  def slices
    return 0 if jobs_count.zero?

    1 + ((jobs_count - 1) / JOBS_SLICE_SIZE)
  end

  def process_in_state_jobs?
    in_state && jobs.nil? && slices.positive?
  end
end
