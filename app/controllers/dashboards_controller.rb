# serves as a starting point when user logs in
# for non admin users, signs out if they are not assigned to any grant
# redirects to an appropriate page depending on the grant and user
class DashboardsController < ApplicationController
  before_filter :authenticate_user!

  def starting_page
    db = Dashboard.new(current_user)

    return redirect_to_not_assigned_path if db.not_assigned?
    return redirect_for_single_grant(db.path) if db.redirect?

    if db.select_grant?
      @grants = current_user.active_grants
      render 'select_grant'
    end
  end

  def grant_selected
    Grant.current_id = session[:grant_id] = params[:grant][:id].to_i
    index
  end

  def index
    db = Dashboard.new(current_user, Grant.find(Grant.current_id), action_name)
    redirect_to db.path
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
