class TraineePlacementsController < ApplicationController
  before_action :authenticate_trainee!, only: [:new, :create]
  before_action :authenticate, only: [:index]

  def new
    trainee = Trainee.find params[:trainee_id]
    @trainee_placement = trainee.trainee_placements.new
  end

  def create
    trainee = Trainee.find params[:trainee_placement][:trainee_id]
    params[:trainee_placement].delete(:trainee_id)
    @trainee_placement = trainee.trainee_placements.new
    if @trainee_placement.update(params[:trainee_placement])
      flash[:notice] = 'New Job Information Saved.'
      redirect_to trainee.job_search_profile
    else
      render 'new'
    end
  end

  def index
    trainee = current_trainee || Trainee.find(params[:trainee_id])
    @trainee_placements = trainee.trainee_placements
  end

private

  def authenticate
    return true if current_user || current_trainee
    fail 'unauthorized access'
  end
end
