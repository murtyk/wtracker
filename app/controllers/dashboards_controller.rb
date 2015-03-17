# serves as a starting point when user logs in
# for non admin users, signs out if they are not assigned to any grant
# redirects to an appropriate page depending on the grant and user
class DashboardsController < ApplicationController
  before_filter :authenticate_user!

  def starting_page
    db = Dashboard.new(current_user)

    return redirect_to_not_assigned_path if db.not_assigned?
    return redirect_to db.path if db.redirect?

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
    db = Dashboard.new(current_user, Grant.find(Grant.current_id))
    redirect_to db.path
  end

  private

  # def init_data
  #   klass_ids = current_user.klasses.map(&:id)
  #   trainee_ids = KlassTrainee.where(klass_id: klass_ids).pluck(:trainee_id)
  #   status_interview = TraineeInteraction::STATUSES.key('Interview')
  #   @interviews = TraineeInteraction.where(trainee_id: trainee_ids,
  #                                          status: status_interview)
  #                 .where('DATE(interview_date) > ?',
  #                        7.days.ago.to_date)
  #                 .order('interview_date desc')
  #   @visits = KlassEvent.where(klass_id: klass_ids)
  #             .where('name ilike ?', '%visit%')
  #             .where('DATE(event_date) >= ?', Time.now.to_date)
  #             .order('event_date desc')
  # end

  def redirect_to_applicant_grant_start_page
    if current_user.navigator?
      redirect_to analysis_applicants_path
    else
      redirect_to dashboards_path
    end
  end

  def redirect_to_not_assigned_path
    sign_out :user
    flash[:error] = 'You are not assigned to any classes yet.
                     Please inform your administrator'
    redirect_to new_user_session_path # Force a full reload
  end
end
