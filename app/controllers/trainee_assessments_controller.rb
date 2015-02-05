class TraineeAssessmentsController < ApplicationController
  before_filter :authenticate_user!

  # GET /trainee_assessments/new
  # GET /trainee_assessments/new.json
  def new
    trainee = Trainee.find(params[:trainee_id])
    @trainee_assessment = trainee.trainee_assessments.build
    logger.info { "[#{current_user.name}] [trainee_assessments new]" }
    authorize @trainee_assessment

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @trainee_assessment }
    end
  end

  # POST /trainee_assessments
  # POST /trainee_assessments.json
  def create
    @trainee_assessment = TraineeAssessment.new(params[:trainee_assessment])
    logger.info { "[#{current_user.name}] [trainee_assessments create]" }
    authorize @trainee_assessment
    @trainee_assessment.save
  end

  def destroy
    @trainee_assessment = TraineeAssessment.find(params[:id])
    @trainee_assessment.destroy
  end
end
