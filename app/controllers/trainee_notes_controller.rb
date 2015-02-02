class TraineeNotesController < ApplicationController
  before_filter :authenticate_user!

  # GET /trainee_notes/new
  # GET /trainee_notes/new.json
  def new
    trainee = Trainee.find(params[:trainee_id])
    @trainee_note = trainee.trainee_notes.build
    authorize @trainee_note
  end

  # GET /trainee_notes/1/edit
  def edit
    @trainee_note = TraineeNote.find(params[:id])
    authorize @trainee_note
  end

  # POST /trainee_notes
  # POST /trainee_notes.json
  def create
    @trainee_note = TraineeNote.new(params[:trainee_note])
    authorize @trainee_note
    @trainee_note.save
    @trainee = @trainee_note.trainee
  end

  # PUT /trainee_notes/1
  # PUT /trainee_notes/1.json
  def update
    @trainee_note = TraineeNote.find(params[:id])
    authorize @trainee_note

    @trainee_note.update_attributes(params[:trainee_note])
  end

  # DELETE /trainee_notes/1
  # DELETE /trainee_notes/1.json
  def destroy
    @trainee_note = TraineeNote.find(params[:id])
    authorize @trainee_note

    @trainee_note.destroy
  end
end
