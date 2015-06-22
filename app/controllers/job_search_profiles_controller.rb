# User can send remiders to trainees for updating their profile
# trainee can update profile including opt out
class JobSearchProfilesController < ApplicationController
  before_action :authenticate_user!, only: [:index, :remind]
  before_action :init_profile, only: [:show, :edit, :update]
  before_action :valid_key!, only: [:show, :edit, :update]

  def remind
    ajl = AutoJobLeads.new
    @trainees = ajl.reminder_trainees(params)
    ajl.delay.remind(params, current_account.id, current_grant.id)
  end

  def index
    @job_search_profiles = JobSearchProfile.where(account_id: current_account.id)
  end

  def show
    capture_trainee_agent

    @auto_shared_jobs = @job_search_profile
                        .auto_shared_jobs(params[:show_all], params[:status])
                        .paginate(page: params[:page], per_page: 15)
  end

  def edit
    @job_search_profile.opted_out ||= params[:opt_out]
    @edit_opt_out = params[:opt_out]
  end

  def update
    if @job_search_profile.update_attributes(profile_params)
      return if request.format.js?
      render 'update'
    else
      render 'edit'
    end
  end

  private

  def profile_params
    p_params = params[:job_search_profile].clone
    start_date = p_params[:start_date]
    p_params[:start_date] = opero_str_to_date(start_date) if start_date
    p_params
  end

  def init_profile
    @job_search_profile = JobSearchProfile.find(params[:id])
    grant_id = @job_search_profile.trainee.grant_id
    Grant.current_id = grant_id
    session[:grant_id] = grant_id
  end

  def valid_key!
    return if @job_search_profile.key == params[:key]
    return if params[:job_search_profile] &&
              @job_search_profile.key == params[:job_search_profile][:key]
    fail 'invalid key for job_search_profile'
  end

  def capture_trainee_agent
    # trainee = current_trainee || find_profile.trainee
    trainee = @job_search_profile.trainee
    return if trainee.agent && trainee.agent.info['ip']

    location_data = request_location_data(trainee.id)
    return unless location_data

    trainee.agent.destroy if trainee.agent
    trainee.create_agent(info: location_data)
  end

  def request_location_data(trainee_id)
    request.location.data
  rescue StandardError => error
    Rails.logger.info "request location error #{error} for trainee id #{trainee_id}"
    nil
  end
end
