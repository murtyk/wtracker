# for trainee (aka applicant, candidate, student) to
#    view and update status on a job lead
class AutoSharedJobsController < ApplicationController
  before_filter :authenticate_user!, only: [:index]
  before_filter :init_auto_shared_job, only: [:edit, :update]

  def index
    @trainee = Trainee.find params[:trainee_id]

    @auto_shared_jobs = AutoSharedJob.where(build_filters)
                        .order(created_at: :desc)
    @count = @auto_shared_jobs.count
    @auto_shared_jobs = @auto_shared_jobs.to_a.paginate(page: params[:page], per_page: 25)
  end

  # REFACTOR explore adding another action for updating notes
  #          status update can be moved to update action?
  def edit
    if params[:status]
      validate_key!
      @auto_shared_job.change_status(params[:status].to_i)
      render 'update'
      return
    end
    if current_trainee && params[:for_notes]
      render 'edit_notes'
      return
    end
    fail 'unauthorized access'
  end

  # REFACTOR right now confined to updating notes only
  #          should move status updates to here
  def update
    fail 'unauthorized access' unless current_trainee
    @auto_shared_job.change_notes(params[:auto_shared_job][:notes])
    render 'update_notes'
  end

  private

  def init_auto_shared_job
    return unless params[:id].to_i > 0
    @auto_shared_job = AutoSharedJob.find(params[:id])
  end

  def validate_key!
    valid_key = @auto_shared_job.valid_key?(params[:key])
    fail 'invalid key for auto job lead' unless valid_key
  end

  def build_filters
    filters  =  { trainee_id: params[:trainee_id] }
    return filters unless params[:status]
    status_codes = AutoSharedJob.status_codes(params[:status])
    filters.merge(status: status_codes)
  end
end
