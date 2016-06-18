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
end
