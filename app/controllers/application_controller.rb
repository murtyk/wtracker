class ApplicationController < ActionController::Base
  around_filter :scope_current_account
  after_filter :user_activity

  include Pundit

  protect_from_forgery
  include SessionsHelper
  include UtilitiesHelper
  include CacheHelper
  include EmployersHelper

  def after_sign_in_path_for(resource)
    if resource.class == Admin
      admin_accounts_path
    elsif resource.class == Trainee
      portal_trainees_path
    else
      startingpage_dashboards_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    if resource_or_scope == :trainee
      new_trainee_session_path
    elsif resource_or_scope == :admin
      new_admin_session_path
    else
      new_user_session_path
    end
  end

  def current_account
    Account.find_by_subdomain! request.subdomain
  end
  helper_method :current_account

  def current_grant
    if session[:grant_id]
      grant = Grant.find(session[:grant_id])
      return grant if grant && grant.active?
    end
    current_account.active_grants.first
  end
  helper_method :current_grant

  def user_or_trainee
    redirect_to root_path unless current_user || current_trainee
  end

  def user_and_no_trainee
    if current_trainee
      redirect_to portal_trainees_path
    else
      authenticate_user!
    end
  end

  private

  def scope_current_account
    # puts request.path_parameters.to_s
    Account.current_id = current_account.id
    Grant.current_id = current_grant.id
    ActionMailer::Base.default_url_options = { host: request.host_with_port }
    yield
  ensure
    Account.current_id = nil
    Grant.current_id = nil
  end

  def user_activity
    current_user.try(:touch, :last_activity_at)
    rescue  => error
      Rails.logger("error in user_activity #{error}")
  end
end
