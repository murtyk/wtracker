# frozen_string_literal: true

class CertificateCategoriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @certificate_categories = CertificateCategory.all

    respond_to do |format|
      format.html
      format.json { render json: @certificate_categories }
    end
  end

  def new
    @certificate_category = CertificateCategory.new
    authorize @certificate_category
  end

  def create
    @certificate_category = CertificateCategory.new(certificate_category_params)
    authorize @certificate_category
    @certificate_category.save
    @certificate_categories = CertificateCategory.all
    respond_to do |format|
      format.js { flash.now[:notice] = 'Certificate Category created successfully.' }
    end
  end

  def destroy
    @certificate_category = CertificateCategory.find(params[:id])
    authorize @certificate_category
    @certificate_category.destroy if @certificate_category.destroyable?
  end

  private

  def certificate_category_params
    params.require(:certificate_category).permit(:code, :name)
  end
end
