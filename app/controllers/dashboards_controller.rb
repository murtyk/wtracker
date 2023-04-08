# frozen_string_literal: true

# serves as a starting point when user logs in
# for non admin users, signs out if they are not assigned to any grant
# redirects to an appropriate page depending on the grant and user
class DashboardsController < ApplicationController
  before_filter :authenticate_user!

  def starting_page
    sp = StartingPage.new(current_user)

    return redirect_to_not_assigned_path if sp.not_assigned?
    return redirect_for_single_grant(sp.path) if sp.redirect?

    if sp.select_grant?
      @grants = current_user.active_grants
      render 'select_grant'
    else
      raise 'unknown action for starting page'
    end
  end

  def grant_selected
    Grant.current_id = session[:grant_id] = params[:grant][:id].to_i
    sp = StartingPage.new(current_user, current_grant)
    redirect_to sp.path
  end

  def index
    @data = DashboardMetrics.generate(current_grant, params.permit!)

    return unless @data.template

    render @data.template
  end

  private

  def redirect_to_not_assigned_path
    sign_out :user
    flash[:error] = 'You are not assigned to any classes yet.
                     Please inform your administrator'
    redirect_to new_user_session_path # Force a full reload
  end

  def redirect_for_single_grant(path)
    grant = current_user.active_grants.first
    Grant.current_id = session[:grant_id] = grant.id
    redirect_to path
  end
end
