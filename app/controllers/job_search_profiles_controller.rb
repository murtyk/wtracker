# Used in the case of 2 types of grants - 1. Auto Job Leads and 2. Applicants
# In case of Applicants grant, trainee can sign in
# in either case trainee can update the profile
# User can send remiders to trainees for updating their profile
class JobSearchProfilesController < ApplicationController
  before_filter :authenticate_user!, only: [:index, :remind]
  before_filter :valid_trainee_or_key, only: [:show, :edit, :update]

  def remind
    ajl = AutoJobLeads.new
    @trainees = ajl.reminder_trainees(params)
    ajl.delay.remind(params, current_account.id, current_grant.id)
  end

  def index
    @job_search_profiles = JobSearchProfile.where(account_id: current_account.id)
  end

  def show
    @job_search_profile = find_profile
    @auto_shared_jobs = @job_search_profile.auto_shared_jobs(params[:show_all],
                                                             params[:status])
                        .paginate(page: params[:page], per_page: 15)
  end

  def edit
    @job_search_profile = find_profile
    @job_search_profile.opted_out ||= params[:opt_out]
    @edit_opt_out = params[:opt_out]
  end

  def update
    @job_search_profile = find_profile
    @edit_opt_out = params[:job_search_profile][:opted_out]

    format_start_date if @edit_opt_out

    if @job_search_profile.update_attributes(params[:job_search_profile])
      if current_trainee
        redirect_to portal_trainees_path
        return
      end
      render 'update'
    else
      render 'edit'
    end
  end

  private

  def find_profile
    return applicant_profile if current_trainee
    jsp = JobSearchProfile.find(params[:id])
    grant_id = jsp.trainee.grant_id
    Grant.current_id = grant_id
    session[:grant_id] = grant_id
    jsp
  end

  def applicant_profile
    applicant      = current_trainee.applicant
    jsp            = current_trainee.job_search_profile
    jsp.location ||= "#{applicant.address_city}, #{applicant.address_state}"
    jsp.zip      ||= applicant.address_zip
    jsp
  end

  def valid_trainee_or_key
    return if current_trainee
    jsp = find_profile
    return if jsp.key == params[:key] || jsp.key == params[:job_search_profile][:key]
    fail 'invalid key for job_search_profile'
  end

  def format_start_date
    return unless params[:job_search_profile][:start_date]
    params[:job_search_profile][:start_date] =
      opero_str_to_date(params[:job_search_profile][:start_date])
  end
end
