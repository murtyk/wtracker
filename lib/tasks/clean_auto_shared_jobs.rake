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

    return unless jobs.any?

    batch = 1

    last_id = jobs.order(:id).last.id
    first_id = jobs.order(:id).first.id

    pos = first_id + 10000

    while true do
      leads = jobs.where("id <= ?", pos)
      puts "Batch #{batch} - #{leads.count}"
      leads.destroy_all
      batch += 1

      break if pos > last_id

      pos += 10000
    end

    puts "Current jobs count = #{AutoSharedJob.count}"
  end
end
