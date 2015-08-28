class AssessmentsController < ApplicationController
  before_action :authenticate_user!

  def new
    @assessment = Assessment.new
  end

  def create
    assessment = Assessment.new(assessment_params)
    assessment.save
    @assessments = Assessment.all
  end

  def index
    @assessments = Assessment.all
  end

  def destroy
    @assessment = Assessment.find(params[:id])
    @assessment.destroy
  end

  private

  def assessment_params
    params.require(:assessment).permit(:name)
  end
end
