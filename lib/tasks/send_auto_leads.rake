# frozen_string_literal: true

namespace :auto_job_leads do
  desc <<-DESC
    Finds job leads and sends them to trainees
    Run using the command 'rake auto_job_leads:send'
  DESC
  task send: :environment do
    before_count = AutoSharedJob.count
    puts "Current Job Leads in DB: #{AutoSharedJob.count}"

    AutoJobLeads.new.perform

    puts "Total leads sent #{AutoSharedJob.count - before_count}"
    puts "Updated jobs count = #{AutoSharedJob.count}"
  end

  task schedule: :environment do
    s = "object:AutoJobLeads\n  statuses: []\nmethod_name: :perform"
    abort 'Jobs already exist.' if Delayed::Job.where("handler like '%#{s}%'").any?

    time = Date.today.to_time + 6.hours
    count = (ENV['AUTO_LEADS_SCHEDULE_COUNT'] || 1000).to_i
    count.times do
      time += 1.day
      AutoJobLeads.new.delay(run_at: time, queue: 'daily').perform
    end

    puts "scheduled for #{count} days."
  end
end
