# frozen_string_literal: true

# Helps to switch between SimplyHired and Indeed at run time
# Defaults to SimplyHired
# we need to set ENV['JOB_BOARD'] to 'Indeed' to switch
require './lib/simply_hired'
require './lib/indeed'

class JobBoard
  extend Forwardable
  extend SingleForwardable

  instance_delegate %i[search_jobs accessible_count jobs user_ip] => :jb
  single_delegate %i[job_count new_store] => :klass

  ANY_KEYWORDS_SEARCH = 1
  ALL_KEYWORDS_SEARCH = 2

  attr_reader :jb

  def initialize(ip = nil)
    jb_klass = JobBoard.klass
    @jb      = jb_klass.new(ip)
  end

  def self.klass
    return SimplyHired unless ENV['JOB_BOARD']

    ENV['JOB_BOARD'].downcase == 'indeed' ? Indeed : SimplyHired
  end
end
