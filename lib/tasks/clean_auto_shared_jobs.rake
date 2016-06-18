namespace :auto_shared_jobs do
  desc <<-DESC
    deletes auto shared jobs older than 2 months
    uses delete_all (not destroy_all) since there no dependencies that need to be deleted
    Run using the command 'rake auto_shared_jobs:clean'
  DESC
  task clean: :environment do
    delete_old_auto_shared_jobs
  end

  desc <<-DESC
    deletes all auto shared jobs
    uses delete_all (not destroy_all) since there no dependencies that need to be deleted
    Run using the command 'rake auto_shared_jobs:clean_all'
  DESC
  task clean_all: :environment do
    puts "Total Job Leads in DB: #{AutoSharedJob.count}"

    while true
      leads = AutoSharedJob.limit(5000)
      if leads.count == 0
        puts "done."
        break;
      end

      puts "Deleting #{leads.count}..."
      leads.each(&:delete)
    end

    puts "Current jobs count = #{AutoSharedJob.count}"
  end

  def delete_old_auto_shared_jobs
    old_date = 1.month.ago
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
      leads.each(&:delete)
      batch += 1

      break if pos > last_id

      pos += 10000
    end

    puts "Current jobs count = #{AutoSharedJob.count}"
  end
end
