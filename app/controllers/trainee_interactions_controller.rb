# all are ajax actions
class TraineeInteractionsController < ApplicationController
  before_action :authenticate_user!

  # GET /trainee_interactions/1
  # GET /trainee_interactions/1.json
  def show
    @trainee_interaction = TraineeInteraction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.js
      format.json { render json: @trainee_interaction }
    end
  end

  # GET /trainee_interactions/new
  # GET /trainee_interactions/new.json
  def new
    @trainee_interaction = TraineeInteractionFactory.build(params)
    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @trainee_interaction }
    end
  end

  # GET /trainee_interactions/1/edit
  def edit
    @trainee_interaction = TraineeInteraction.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.js
      format.json { render json: @trainee_interaction }
    end
  end

  # POST /trainee_interactions
  # POST /trainee_interactions.json
  def create
    # object is either Employer or Trainee
    @object = TraineeInteractionFactory.create(params)
  end

  # PUT /trainee_interactions/1
  # PUT /trainee_interactions/1.json
  def update
    @trainee_interaction = TraineeInteractionFactory.update(params)
    @trainee = @trainee_interaction.trainee
  end

  # DELETE /trainee_interactions/1
  # DELETE /trainee_interactions/1.json
  def destroy
    @trainee_interaction = TraineeInteractionFactory.destroy(params)
    @trainee = @trainee_interaction.trainee
  end
end
