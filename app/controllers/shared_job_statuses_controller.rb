class SharedJobStatusesController < ApplicationController
  before_filter :authenticate_user!, only: [:index, :enquire]

  def index
    @shared_job_statuses = SharedJobStatus.search(params[:filters])

    unless request.format.xls?
      @shared_job_statuses = @shared_job_statuses.to_a.paginate(page: params[:page],
                                                                per_page: 10)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xls
      format.json { render json: @shared_job_statuses }
    end
  end

  def enquire
    @shared_job_status = SharedJobStatus.find(params[:id])
    JobStatusServices.send_job_lead_status_enquiry @shared_job_status
  end

  def show
    @shared_job_status = SharedJobStatus.find(params[:id])

    @valid_key = @shared_job_status.key == params[:key]

    @shared_job_status = nil unless @valid_key

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @shared_job_status }
    end
  end

  # PUT /shared_job_statuses/1
  # PUT /shared_job_statuses/1.json
  def update
    @shared_job_status = SharedJobStatus.find(params[:id])

    respond_to do |format|
      if @shared_job_status.update_attributes(params[:shared_job_status])
        url = shared_job_status_path(@shared_job_status, key: @shared_job_status.key)
        notice = 'Thank you for your feedback.'
        format.html { redirect_to url, notice: notice }
        format.json { head :no_content }
      else
        format.html { render 'edit' }
        errors = @shared_job_status.errors
        format.json { render json: errors, status: :unprocessable_entity }
      end
    end
  end

  def clicked
    @shared_job_status = SharedJobStatus.find(params[:id])

    @valid_key = @shared_job_status.clicked(params[:key])

    # debugger
    if @valid_key
      redirect_to @shared_job_status.job_details_url
    else
      render 'show'
      # redirect_to shared_job_status_path(@shared_job_status,
      #                                    key: @shared_job_status.key)
    end
  end
end
