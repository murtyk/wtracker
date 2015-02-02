class AssessmentsController < ApplicationController
  before_filter :authenticate_user!

  # GET /account_states/new.js
  def new
    @assessment = Assessment.new
  end

  # POST /account_states.js
  def create
    assessment = Assessment.new(name: params[:assessment][:name])
    assessment.save
    @assessments = Assessment.all
  end

  def index
    @assessments = Assessment.all
  end

  # DELETE /account_states/1.js
  def destroy
    @assessment = Assessment.find(params[:id])
    @assessment.destroy
  end
end
