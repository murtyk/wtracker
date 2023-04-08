# frozen_string_literal: true

class MentorsController < ApplicationController
  before_filter :authenticate_user!

  def new
    trainee = Trainee.find(params[:trainee_id])
    @mentor = trainee.build_mentor
    authorize @mentor
  end

  def create
    @trainee = Trainee.find(params[:mentor][:trainee_id])
    @mentor = @trainee.build_mentor(mentor_params)
    authorize @mentor
    @mentor.save
  end

  def edit
    @mentor = Mentor.find(params[:id])
    authorize @mentor
  end

  def update
    @mentor = Mentor.find(params[:id])
    authorize @mentor

    @mentor.update_attributes(mentor_params)
  end

  def destroy
    @mentor = Mentor.find(params[:id])
    authorize @mentor

    @mentor.destroy
  end

  private

  def mentor_params
    params.require(:mentor)
          .permit(:name, :email, :phone)
  end
end
