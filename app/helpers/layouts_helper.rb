# for page layout menus etc. based on who signed
module LayoutsHelper
  def top_bar
    return 'trainee_portal_topbar' if trainee_portal?
    return 'clienttopbar' if admin_signed_in? && user_signed_in?
    return 'admintopbar' if admin_signed_in?
    return 'clienttopbar' if user_signed_in? && current_user

    top_bar_based_on_request
  end

  def trainee_portal?
    trainee_signed_in? ||
      controller_name == 'applicants' ||
      controller_name == 'applicant_reapplies' ||
      request.path == '/trainees/sign_in' ||
      request.path == '/trainees/password/new'
  end

  def top_bar_based_on_request
    return 'traineetopbar' if controller_name == 'shared_job_statuses'
    return 'auto_job_leads' if controller_name == 'job_search_profiles'
    'hometopbar'
  end
end
