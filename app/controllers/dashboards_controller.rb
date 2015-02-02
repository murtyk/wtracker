class DashboardsController < ApplicationController
  before_filter :authenticate_user!

  def startingpage
    @grants = current_user.active_grants
    if @grants.empty?
      sign_out :user
      flash[:error] = 'You are not assigned to any classes yet.
                       Please inform your administrator'
      redirect_to new_user_session_path # Force a full reload
      return
    end

    if @grants.count > 1
      render 'select_grant'
      return
    end

    Grant.current_id   = @grants.first.id
    session[:grant_id] = Grant.current_id

    if current_grant.trainee_applications?
      if current_user.navigator?
        redirect_to analysis_applicants_path
        return
      end
      @applicant_metrics = ApplicantMetrics.new.generate(current_user)
      render 'applicant_metrics'
      return
    end
    if current_user.admin_or_director? || current_user.grant_admin?
      render 'summary'
      return
    end

    # we come here when there is only one grant and user is not admin_or_director
    redirect_to current_user.klasses.first
  end

  def grantselected
    Grant.current_id = session[:grant_id] = params[:grant][:id].to_i
    if current_grant.trainee_applications?
      @applicant_metrics = ApplicantMetrics.new.generate(current_user)
      render 'applicant_metrics'
      return
    end
    init_data if current_user.navigator?
    render 'summary'
  end

  def summary
    if current_grant.trainee_applications?
      @applicant_metrics = ApplicantMetrics.new.generate(current_user)
      render 'applicant_metrics'
      return
    end
    init_data if current_user.navigator? || current_user.instructor?
  end

  private

  def init_data
    klass_ids = current_user.klasses.map(&:id)
    trainee_ids = KlassTrainee.where(klass_id: klass_ids).pluck(:trainee_id)
    status_interview = TraineeInteraction::STATUSES.key('Interview')
    @interviews = TraineeInteraction.where(trainee_id: trainee_ids,
                                           status: status_interview)
                                    .where('DATE(interview_date) > ?',
                                           7.days.ago.to_date)
                                    .order('interview_date desc')
    @visits = KlassEvent.where(klass_id: klass_ids)
                        .where('name ilike ?', '%visit%')
                        .where('DATE(event_date) >= ?', Time.now.to_date)
                        .order('event_date desc')
  end
end
