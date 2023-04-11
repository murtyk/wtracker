# frozen_string_literal: true

class UiVerifiedNotesController < ApplicationController
  before_action :authenticate_user!

  # GET /ui_verified_notes/new
  # GET /ui_verified_notes/new.json
  def new
    trainee = Trainee.find(params[:trainee_id])
    @ui_verified_note = trainee.ui_verified_notes.build
    authorize @ui_verified_note
  end

  # POST /ui_verified_notes
  # POST /ui_verified_notes.json
  def create
    attributes = ui_verified_note_params.merge(user_id: current_user.id)
    @ui_verified_note = UiVerifiedNote.new(attributes)
    authorize @ui_verified_note
    @ui_verified_note.save
    @trainee = @ui_verified_note.trainee
  end

  # DELETE /ui_verified_notes/1
  # DELETE /ui_verified_notes/1.json
  def destroy
    @ui_verified_note = UiVerifiedNote.find(params[:id])
    authorize @ui_verified_note

    @ui_verified_note.destroy
  end

  private

  def ui_verified_note_params
    params.require(:ui_verified_note)
          .permit(:notes, :trainee_id)
  end
end
