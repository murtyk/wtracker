class TraineeFilesController < ApplicationController
  before_filter :authenticate_user!, only: [:destroy]
  before_action :authenticate, only: [:show, :new, :create]

  # GET /trainee_files/1
  # GET /trainee_files/1.json
  def show
    @trainee_file = TraineeFile.find(params[:id])
    url = Amazon.file_url @trainee_file.file
    redirect_to url.to_s
  end

  # GET /trainee_files/new
  # GET /trainee_files/new.json
  def new
    trainee = Trainee.find(params[:trainee_id])
    @trainee_file = trainee.trainee_files.new
  end

  # POST /trainee_files
  # POST /trainee_files.json
  def create
    saved,
    @error_message,
    @trainee_file = TraineeFactory.add_trainee_file(trainee_file_params,
                                                    current_user || current_trainee)

    if saved
      notice = 'file was successfully saved.'
      if current_trainee
        redirect_to(portal_trainees_path, notice: notice)
      end
    else
      if current_trainee
        redirect_to(portal_trainees_path(error_message: @error_message),
                    alert: 'error saving file')
      end
    end
  end

  # DELETE /trainee_files/1
  # DELETE /trainee_files/1.json
  def destroy
    @trainee_file = TraineeFile.find(params[:id])
    @trainee_file.destroy

    respond_to do |format|
      format.html { redirect_to trainee_files_url }
      format.js
      format.json { head :no_content }
    end
  end

  def authenticate
    current_user || current_trainee
  end

  private

  def trainee_file_params
    params.require(:trainee_file)
      .permit(:file, :notes, :uploaded_by, :trainee_id)
  end
end
