# frozen_string_literal: true

# user can browse the job leads for a trainee
# Trainee can view and update status on a job lead
class AutoSharedJobsController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  before_action :init_auto_shared_job, only: [:update]
  before_action :validate_key!, only: [:update]

  def index
    @trainee = Trainee.find params[:trainee_id]

    @auto_shared_jobs = AutoSharedJob.where(build_filters)
                                     .order(created_at: :desc)
    @count = @auto_shared_jobs.count
    @auto_shared_jobs = @auto_shared_jobs
                        .paginate(page: params[:page], per_page: 25)
  end

  def update
    @auto_shared_job.change_status(params[:status].to_i)
  end

  private

  def init_auto_shared_job
    return unless params[:id].to_i.positive?

    @auto_shared_job = AutoSharedJob.find(params[:id])
  end

  def validate_key!
    valid_key = @auto_shared_job.valid_key?(params[:key])
    raise 'invalid key for auto job lead' unless valid_key
  end

  def build_filters
    filters = { trainee_id: params[:trainee_id] }
    return filters unless params[:status]

    status_codes = AutoSharedJob.status_codes(params[:status])
    filters.merge(status: status_codes)
  end
end
