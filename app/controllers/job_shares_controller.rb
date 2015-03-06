class JobSharesController < ApplicationController
  before_filter :authenticate_user!

  # GET /job_shares
  # GET /job_shares.json
  def index
    @job_shares = JobShare.search(params[:filters])

    unless request.format.xls?
      @job_shares = @job_shares.to_a.paginate(page: params[:page], per_page: 10)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xls
      format.json { render json: @job_shares }
    end
  end

  # GET /job_shares/1
  # GET /job_shares/1.json
  def show
    @job_share = JobShare.find(params[:id])
    authorize @job_share

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @job_share }
    end
  end

  # GET /job_shares/new
  # GET /job_shares/new.json
  def new
    @job_share = JobShare.new(params[:job_info])
    authorize @job_share
    @job_share.klass_id = current_user.last_klass_selected
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @job_share }
    end
  end

  def new_multiple
    @job_share  = JobShareFactory.new_multiple(params, current_user)
  end

  def company_status
    company = JobSearchServices.company_and_jobs_from_cache([params[:job_id]])
    status  = company.status
    # debugger
    respond_to do |format|
      format.json { render json: status }
    end
  end

  # POST /job_shares
  # POST /job_shares.json
  def create
    # authorize @job_share

    @job_share = JobShareFactory.create_job_share(params, current_user)
    json_job_share = { job_share_id: @job_share.id, errors: @job_share.errors }

    respond_to do |format|
      if @job_share.errors.empty?
        format.html { redirect_to @job_share, notice: 'Job(s) shared successfully.' }
        format.json { render json: json_job_share, status: :created }
      else
        format.html { render :new }
        format.json { render json: json_job_share, status: :unprocessable_entity }
      end
    end
  end

  def send_to_trainee
    begin
      JobShareFactory.send_to_trainee(params)
      trainee = Trainee.find(params[:trainee_id])
      message = trainee.name
    rescue StandardError => error
       # debugger
       message = error
    end
    respond_to do |format|
      format.json { render json: { message: message }, status: :created }
    end
  end
end
