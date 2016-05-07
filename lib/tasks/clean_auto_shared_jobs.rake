namespace :auto_shared_jobs do
  desc <<-DESC
    deletes auto shared jobs older than 2 months
    Run using the command 'rake auto_shared_jobs:clean'
  DESC
  task clean: :environment do
    destroy_old_auto_shared_jobs
  end

  def destroy_old_auto_shared_jobs
    old_date = 2.months.ago
    jobs = AutoSharedJob.where("created_at < ?", old_date)
    puts "Deleting #{jobs.count} leads that older than #{old_date.to_s}"

    batch = 1

    jobs.find_in_batches do |group|
      puts "Batch #{batch} - #{group.count}"
      group.destroy_all
      batch += 1
    end

    puts "Current jobs count = #{AutoSharedJob.count}"
  end
end
