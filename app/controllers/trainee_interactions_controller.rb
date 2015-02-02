class TraineeInteractionsController < ApplicationController
  before_filter :authenticate_user!

  def traineelist
    # debugger
    @trainees_list = TraineeInteractionFactory.trainee_list_for_selection(params)

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @trainees_list }
    end
  end

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
    @trainee_page, @trainee_interaction = TraineeInteractionFactory.build(params)

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @trainee_interaction }
    end
  end

  # GET /trainee_interactions/1/edit
  def edit
    @trainee_interaction = TraineeInteraction.find(params[:id])
    @trainee_page = params[:trainee_page] == 'true'

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
    @object, @trainee_interaction = TraineeInteractionFactory.update(params)
  end

  # DELETE /trainee_interactions/1
  # DELETE /trainee_interactions/1.json
  def destroy
    @trainee_interaction = TraineeInteraction.find(params[:id])
    @trainee_page = params[:trainee_page] == 'true'
    @trainee_interaction.destroy
  end
end
