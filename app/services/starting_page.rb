# frozen_string_literal: true

# User's starting page depends on the grant(s) and user role
#
# Action: Starting Page (sign in)
#   Case 1: User has no grants  ---> Not Assigned Message
#   Case 2: User has one grant  ---> User starting page
#   Case 3: User has > 1 grants ---> Select Grant
#
# Action: Grant Selection
#
# On Grant Selection:
# Applicant Grant
#   Direcotr/Admin   --> Dashboard
#   Navigator        --> Applicants Analysis
#   Instructor       --> Classes
#
# Auto Leads Grant
#   Direcotr/Admin   --> Dashboard
#   Navigator(admin access) --> Dashboard
#   Navigator        --> Classes
#   Instructor       --> Classes
#
# Standard Grant
#   Direcotr/Admin          --> Dashboard
#   Navigator(admin access) --> Dashboard
#   Navigator               --> Classes
#   Instructor              --> Classes
class StartingPage
  attr_reader :grant, :user, :template, :path

  def initialize(user, g = nil)
    @user  = user
    @grant = g || set_grant_context
    determine_action if grant # only one grant
  end

  def determine_action
    return dashboard_action if user.admin? || user.director?
    return nav_action if user.navigator?

    instructor_action
  end

  def set_grant_context
    grants = user.active_grants
    return grants.first if grants.count == 1

    @action = grants.empty? ? :not_assigned : :select_grant
    nil
  end

  # navigator starting page
  # Applicant Grant    --> Redirect to Applicants Analysis
  # Auto Leads Grant   --> Dashboard
  # Standard Grant
  #   Navigator(admin access) --> Dashboard
  #   Navigator        --> Classes
  def nav_action
    return applicant_analysis_action if grant.trainee_applications?
    return dashboard_action if user.admin_access?

    klasses_page
  end

  # instructor is always shown classes
  def instructor_action
    klasses_page
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

  def dashboard_action
    action_redirect h.dashboards_path
  end

  def applicant_analysis_action
    action_redirect h.analysis_applicants_path
  end

  def klasses_page
    action_redirect h.klasses_path
  end

  def action_redirect(page)
    @action = :redirect
    @path   = page
  end

  def h
    Rails.application.routes.url_helpers
  end
end
