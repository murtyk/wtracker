# frozen_string_literal: true

namespace :auto_shared_jobs do
  desc <<-DESC
    deletes auto shared jobs older than 2 months
    uses delete_all (not destroy_all) since there are no dependencies that need to be deleted
    Run using the command 'rake auto_shared_jobs:clean'
  DESC
  task clean: :environment do
    AutoSharedJobsCleaner.clean(false)
  end

  desc <<-DESC
    deletes all auto shared jobs
    uses delete_all (not destroy_all) since there are no dependencies that need to be deleted
    Run using the command 'rake auto_shared_jobs:clean_all'
  DESC
  task clean_all: :environment do
    AutoSharedJobsCleaner.clean(true)
  end
end
