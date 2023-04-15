# frozen_string_literal: true

class EmployerNotesController < ApplicationController
  before_action :authenticate_user!

  # GET /employer_notes/new
  # GET /employer_notes/new.json
  def new
    @employer_note = EmployerNote.new(employer_id: params[:employer_id])
    authorize @employer_note
  end

  # POST /employer_notes
  # POST /employer_notes.json
  def create
    @employer_note = EmployerNote.new(employer_note_params)
    authorize @employer_note
    @employer_note.save
  end

  def edit
    @employer_note = EmployerNote.find(params[:id])
    authorize @employer_note
  end

  def update
    @employer_note = EmployerNote.find(params[:id])
    authorize @employer_note
    @employer_note.update(note: params[:employer_note][:note])
  end

  # DELETE /employer_notes/1
  # DELETE /employer_notes/1.json
  def destroy
    @employer_note = EmployerNote.find(params[:id])
    authorize @employer_note
    @employer_note.destroy
  end

  private

  def employer_note_params
    params.require(:employer_note).permit(:employer_id, :note)
  end
end
