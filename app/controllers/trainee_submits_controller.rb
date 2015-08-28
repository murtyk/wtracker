class TraineeSubmitsController < ApplicationController
  before_filter :authenticate_user!

  # GET /trainee_submits/new
  # GET /trainee_submits/new.json
  def new
    @trainee_submit = Trainee.find(params[:trainee_id]).trainee_submits.new
    authorize @trainee_submit
  end

  # POST /trainee_submits
  # POST /trainee_submits.json
  def create
    @trainee_submit = build_trainee_submit
    logger.info { "[#{current_user.name}] [trainee_submit create]" }
    authorize @trainee_submit
    @trainee_submit.save
  end

  private

  def build_trainee_submit
    trainee = Trainee.find(params[:trainee_submit][:trainee_id])

    trainee.trainee_submits.new(trainee_submit_params)
  end

  def trainee_submit_params
    ts_params = params.require(:trainee_submit)
                .permit(:title, :employer_id, :applied_on)

    ts_params[:applied_on] = opero_str_to_date(ts_params[:applied_on])
    ts_params
  end
end
