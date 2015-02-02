class TraineeSubmitsController < ApplicationController
  before_filter :authenticate_user!

  # GET /trainee_submits/new
  # GET /trainee_submits/new.json
  def new
    trainee = Trainee.find(params[:trainee_id])
    @trainee_submit = trainee.trainee_submits.new
    logger.info { "[#{current_user.name}] [trainee_submit new]" }
    authorize @trainee_submit

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @trainee_submit }
    end
  end

  # POST /trainee_submits
  # POST /trainee_submits.json
  def create
    trainee = Trainee.find(params[:trainee_submit].delete(:trainee_id))

    @trainee_submit = trainee.trainee_submits.new(params[:trainee_submit])
    @trainee_submit.applied_on = opero_str_to_date(params[:trainee_submit][:applied_on])

    logger.info { "[#{current_user.name}] [trainee_submit create]" }
    authorize @trainee_submit
    @trainee_submit.save
  end
end
