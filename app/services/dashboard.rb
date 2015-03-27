# User's dashboard depends on the grant and user role
# Applicant Grant
#   Direcotr/Admin   --> Render Applicants Dashboard
#   Navigator        --> Redirect to Applicants Analysis
#   Instructor       --> Classes
#
# Auto Leads Grant
#   Direcotr/Admin   --> Render Auto Leads Dashboard
#   Navigator(admin access) --> Render Auto Leads Dashboard
#   Navigator        --> Redirect to Classes
#   Instructor       --> Redirect to Classes
#
# Standard Grant
#   Direcotr/Admin          --> Render Common (Programs overview)
#   Navigator(admin access) --> Render Common
#   Navigator               --> Redirect to Classes
#   Instructor              --> Redirect to Classes
class Dashboard
  attr_reader :grant, :user
  attr_reader :template, :path
  def initialize(user, g = nil, controller_action = nil)
    @user  = user
    @grant = g || set_grant_context
    determine_action(controller_action) if grant
  end

  def determine_action(controller_action)
    return admin_action if user.admin? || user.director?
    return nav_action(controller_action) if user.navigator?
    instructor_action
  end

  def set_grant_context
    grants = user.active_grants
    return grants.first if grants.count == 1
    @action = grants.empty? ? :not_assigned : :select_grant
    nil
  end

  # admin dashboard data
  # Applicant Grant   --> Render Applicants Dashboard
  # Auto Leads Grant  --> Render Auto Leads Dashboard
  # Standard Grant    --> Render Common (Programs overview)
  def admin_action
    return trainee_applications_action if grant.trainee_applications?
    return auto_job_leads_action if grant.auto_job_leads?
    standard_dashboard
  end

  # navigator dashboard data
  # Applicant Grant    --> Redirect to Applicants Analysis
  # Auto Leads Grant   --> Render Auto Leads Dashboard
  # Standard Grant
  #   Navigator(admin access) --> Render Common
  #   Navigator        --> Redirect to Classes
  def nav_action(controller_action)

    if grant.trainee_applications?
      return trainee_applications_action if controller_action == 'index'
      return applicant_analysis_action
    end

    if user.admin_access?
      return auto_job_leads_action if grant.auto_job_leads?
      return standard_dashboard
    end

    action_redirect h.klasses_path
  end

  # instructor is always shown classes
  def instructor_action
    action_redirect h.klasses_path
  end

  def render?
    @action == :render
  end

  def redirect?
    @action == :redirect
  end

  def not_assigned?
    @action == :not_assigned
  end

  def select_grant?
    @action == :select_grant
  end

  private

  def trainee_applications_action
    action_redirect h.applicants_metrics_path
  end

  def auto_job_leads_action
    action_redirect h.auto_leads_metrics_path
  end

  def standard_dashboard
    action_redirect h.standard_metrics_path
  end

  def applicant_analysis_action
    action_redirect h.analysis_applicants_path
  end

  def action_render(page)
    @template = page
    @action = :render
  end

  def action_redirect(page)
    @action = :redirect
    @path   = page
  end

  def h
    Rails.application.routes.url_helpers
  end
end
