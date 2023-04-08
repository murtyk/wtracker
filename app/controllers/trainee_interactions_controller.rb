# frozen_string_literal: true

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
    @trainee_interaction = TraineeInteractionFactory.build(trainee_id)
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
    @object = TraineeInteractionFactory.create(trainee_id,
                                               trainee_interaction_params)
  end

  # PUT /trainee_interactions/1
  # PUT /trainee_interactions/1.json
  def update
    @trainee_interaction = TraineeInteractionFactory
                           .update(params[:id], trainee_interaction_params)
    @trainee = @trainee_interaction.trainee
  end

  # DELETE /trainee_interactions/1
  # DELETE /trainee_interactions/1.json
  def destroy
    @trainee_interaction = TraineeInteractionFactory.destroy(params[:id])
    @trainee = @trainee_interaction.trainee
  end

  private

  def trainee_interaction_params
    params.require(:trainee_interaction)
          .permit(:employer_id, :comment, :status, :company, :employer_name,
                  :start_date, :hire_salary, :hire_title, :termination_date,
                  :klass_id, :trainee_ids, :employer_name, :completion_date,
                  :uses_trained_skills)
  end

  def trainee_id
    params[:trainee_id] || params[:trainee_interaction][:trainee_id]
  end
end
