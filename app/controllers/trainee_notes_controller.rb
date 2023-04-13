# frozen_string_literal: true

class TraineeNotesController < ApplicationController
  before_action :authenticate_user!

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
    @trainee_note = TraineeNote.new(traiee_note_params)
    authorize @trainee_note
    @trainee_note.save
    @trainee = @trainee_note.trainee
  end

  # PUT /trainee_notes/1
  # PUT /trainee_notes/1.json
  def update
    @trainee_note = TraineeNote.find(params[:id])
    authorize @trainee_note

    @trainee_note.update_attributes(traiee_note_params)
  end

  # DELETE /trainee_notes/1
  # DELETE /trainee_notes/1.json
  def destroy
    @trainee_note = TraineeNote.find(params[:id])
    authorize @trainee_note

    @trainee_note.destroy
  end

  private

  def traiee_note_params
    params.require(:trainee_note)
          .permit(:notes, :trainee_id)
  end
end
