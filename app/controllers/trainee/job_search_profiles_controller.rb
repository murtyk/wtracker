# frozen_string_literal: true

class Trainee
  # Trainee signed in
  # can enter/update job search data
  # can opt out
  class JobSearchProfilesController < TraineePortalController
    def edit; end

    def update
      if @job_search_profile.update(jsp_params)
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

    def jsp_params
      params.require(:job_search_profile)
            .permit(:key, :skills, :location, :zip, :distance, :opted_out)
    end
  end
end
