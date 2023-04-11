# frozen_string_literal: true

class KlassCategoriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @klass_categories = KlassCategory.all

    respond_to do |format|
      format.html
      format.json { render json: @klass_categories }
    end
  end

  def new
    @klass_category = KlassCategory.new
    authorize @klass_category
  end

  def create
    @klass_category = KlassCategory.new(klass_category_params)
    authorize @klass_category
    @klass_category.save
    @klass_categories = KlassCategory.all
    respond_to do |format|
      format.js { flash.now[:notice] = 'Class Category created successfully.' }
    end
  end

  def destroy
    @klass_category = KlassCategory.find(params[:id])
    authorize @klass_category
    @klass_category.destroy if @klass_category.klasses.empty?
  end

  private

  def klass_category_params
    params.require(:klass_category).permit(:code, :description)
  end
end
