# frozen_string_literal: true

class ApplicationController < ActionController::Base
  around_action :scope_current_account
  # after_filter :user_activity

  include Pundit

  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token,
                     if: proc { |c| c.request.format == 'application/json' }

  include SessionsHelper
  include UtilitiesHelper
  include CacheHelper
  include EmployersHelper

  def after_sign_in_path_for(resource)
    case resource
    when Admin
      admin_accounts_path
    when Trainee
      portal_trainee_trainee_path(resource)
    else
      starting_page_dashboards_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    case resource_or_scope
    when :trainee
      new_trainee_session_path
    when :admin
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
      return grant if grant
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

  def default_serializer_options
    { root: false }
  end

  private

  def scope_current_account
    # puts request.path_parameters.to_s
    Account.current_id = current_account.id
    grant_for_trainee_sign_in
    Grant.current_id = current_grant.id
    ActionMailer::Base.default_url_options = { host: request.host_with_port }
    yield
  ensure
    Account.current_id = nil
    Grant.current_id = nil
  end

  def grant_for_trainee_sign_in
    return unless request.path == '/trainees/sign_in'

    grant = Grant.all.select(&:trainee_applications?).first
    return unless grant

    session[:grant_id] = grant.id
  end

  # def user_activity
  #   current_user.try(:touch, :last_activity_at)
  #   rescue  => error
  #     Rails.logger("error in user_activity #{error}")
  # end
end
