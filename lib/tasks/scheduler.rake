task :clean_auto_shared_jobs => :environment do
  AutoSharedJobsCleaner.delay(queue: "daily").clean(false)
end
