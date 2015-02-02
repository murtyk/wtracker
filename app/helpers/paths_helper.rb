# helper for creating buttons with icons
module PathsHelper
  def jsp_path(jsp, filters)
    params = current_grant.trainee_applications? ? {} : { key: jsp.key }
    job_search_profile_path(jsp, params.merge(filters))
  end
end
