# frozen_string_literal: true

require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  # configure do |config|
  #   config[:sleep_timeout] = 300  # wakes up every 5 minutes
  # end

  # handler do |job|
  #   if job == 'AUTOLEADS'
  #     # Rails.logger.info "Running #{job} #{Date.today}"
  #     # AutoJobLeads.new.perform
  #     Rails.logger.info "Handler #{job} #{Time.now}"
  #     perform = true
  #     asj = AutoSharedJob.last
  #     if asj
  #       prev_date = Date.parse(asj.created_at.to_s)
  #       perform = Date.today > prev_date
  #       Rails.logger.info "Handler #{job} prev_date: #{prev_date.to_s}"
  #     end
  #     Rails.logger.info "Handler #{job} skipping" unless perform
  #     Rails.logger.info "Handler #{job} performing" if perform
  #     AutoJobLeads.new.perform if perform
  #   else
  #     Rails.logger.info "Handler #{job} #{Time.now}"
  #   end
  # end

  # every(10.minutes, 'TENMINUTEJOB')
  # every(1.hour, 'ONEHOURJOB')
  # every(1.hour, 'AUTOLEADS')
  # every(1.day, 'AUTOLEADS', at: '6:00')
  # every(1.day, 'DAILYJOB')
  # every(1.day, 'DAILYJOBAT6AM', at: '6:00')
  # every(1.day, 'DAILYJOBAT8AM', at: '8:00')
end
