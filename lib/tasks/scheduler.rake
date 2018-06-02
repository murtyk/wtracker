# 2:00 UTC
task :generate_profiles => :environment do
  Rails.logger.info 'Scheduler: generate_profiles'
  AutoProfileGenerator.delay(queue: "daily").generate
end

# 3:00 UTC
task :clean_auto_shared_jobs => :environment do
  Rails.logger.info 'Scheduler: clean_auto_shared_jobs'
  AutoSharedJobsCleaner.delay(queue: "daily").clean(false)
end

# 06:00:00 UTC
task :queue_auto_leads => :environment do
  Rails.logger.info 'Scheduler: queue_auto_leads'
  QueueAutoLeadsJobs.delay(queue: "daily").perform
end

# 09:00:00 UTC
task :update_klass_trainees_status => :environment do
  Rails.logger.info 'Scheduler: update_klass_trainees_status'
  DailyKlassTraineeStatus.delay(queue: "daily").perform
end
