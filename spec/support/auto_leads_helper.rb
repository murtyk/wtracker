module AutoLeadsHelper
  def clean_job_search_profiles
    JobSearchProfile.unscoped.destroy_all
    AutoSharedJob.unscoped.destroy_all
  end
end
