# frozen_string_literal: true

class ApplicantSourcesController < ApplicationController
  before_action :authenticate_user!

  def index
    @applicant_sources = ApplicantSource.all
  end

  def new
    @applicant_source = ApplicantSource.new
    authorize @applicant_source
  end

  def create
    applicant_source = ApplicantSource.new(applicant_source_params)
    authorize applicant_source
    applicant_source.save
    @applicant_sources = ApplicantSource.order(:source)
  end

  def destroy
    @applicant_source = ApplicantSource.find(params[:id])
    authorize @applicant_source
    @applicant_source.destroy
  end

  private

  def applicant_source_params
    params.require(:applicant_source).permit(:source)
  end
end
