class JobSearchProfilesController < ApplicationController
  before_filter :authenticate_user!, only: [:index, :remind]

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
    unless current_trainee || @job_search_profile.valid_key?(params[:key])
      fail 'invalid key for job_search_profile show'
    end
    @auto_shared_jobs = @job_search_profile.auto_shared_jobs(params[:show_all],
                                                             params[:status])
                                           .paginate(page: params[:page], per_page: 15)
  end

  def edit
    @job_search_profile = find_profile
    fail 'slug mismatch error' unless @job_search_profile.key == params[:key]
    @job_search_profile.opted_out ||= params[:opt_out]
    @edit_opt_out = params[:opt_out]
  end

  def update
    @job_search_profile = find_profile
    @edit_opt_out = params[:job_search_profile][:opted_out]

    unless current_trainee || @job_search_profile.key == params[:job_search_profile][:key]
      fail 'slug mismatch error in update action'
    end

    if @edit_opt_out && params[:job_search_profile][:start_date]
      params[:job_search_profile][:start_date] =
                              opero_str_to_date(params[:job_search_profile][:start_date])
    end

    respond_to do |format|
      if @job_search_profile.update_attributes(params[:job_search_profile])
        # url = job_search_profile_path(@job_search_profile, key: @job_search_profile.key)
        if current_trainee
          redirect_to portal_trainees_path
          return
        end
        format.html { render 'update' }
      else
        format.html { render 'edit' }
      end
    end
  end

  private

  def find_profile
    if current_trainee
      applicant      = current_trainee.applicant
      jsp            = current_trainee.job_search_profile
      jsp.location ||= "#{applicant.address_city}, #{applicant.address_state}"
      jsp.zip      ||= applicant.address_zip
      return jsp
    end
    JobSearchProfile.find(params[:id])
  end
end
