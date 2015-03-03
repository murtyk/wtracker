# for job search new and show pages
module JobSearchesHelper
  def show_titles_job_counts
    return false if current_user.admin_access? || current_user.grant_admins.any?
    current_user.navigator?
  end
end
