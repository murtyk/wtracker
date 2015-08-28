class TraineePlacementsController < ApplicationController
  before_action :authenticate_trainee!, only: [:new, :create]
  before_action :authenticate, only: [:index]

  def new
    trainee = Trainee.find params[:trainee_id]
    @trainee_placement = trainee.trainee_placements.new
  end

  def create
    trainee = Trainee.find params[:trainee_placement][:trainee_id]
    @trainee_placement = trainee.trainee_placements.new
    if @trainee_placement.update(trainee_placement_params)
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

  def trainee_placement_params
    params.require(:trainee_placement)
      .permit(:company_name, :address_line1, :address_line2, :city,
              :state, :zip, :phone_no, :salary, :job_title, :start_date,
              :reported_date, :placement_type)
  end
end
