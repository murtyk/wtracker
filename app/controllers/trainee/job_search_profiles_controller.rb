class Trainee
  # Trainee signed in
  # can enter/update job search data
  # can opt out
  class JobSearchProfilesController < TraineePortalController
    def edit
    end

    def update
      if @job_search_profile.update_attributes(params[:job_search_profile])
        if params[:job_search_profile][:opted_out]
          render 'opted_out'
        else
          perform_portal_action
        end
      else
        render 'edit'
      end
    end

    def show
      @auto_shared_jobs = @job_search_profile
                          .auto_shared_jobs(params[:show_all], params[:status])
                          .paginate(page: params[:page], per_page: 15)
    end
  end
end
