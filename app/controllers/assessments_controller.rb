class AssessmentsController < ApplicationController
  before_action :authenticate_user!

  def new
    @assessment = Assessment.new
  end

  def create
    assessment = Assessment.new(assessment_params)

    if assessment.save
      render json: assessment
    else
      render json: assessment.errors, status: 422
    end

    return
  end

  def index
    @assessments = Assessment.all
  end

  def destroy
    @assessment = Assessment.find(params[:id])
    @assessment.destroy

    render json: {}, status: 200
  end

  private

  def assessment_params
    params.require(:assessment).permit(:name)
  end
end
