# frozen_string_literal: true

class CollegesController < ApplicationController
  before_action :authenticate_user!
  # GET /colleges
  def index
    @colleges_map = CollegesMap.new
  end

  # GET /colleges/1
  def show
    @college = College.find(params[:id])
    authorize @college
  end

  # GET /colleges/new
  # GET /colleges/new.json
  def new
    @college = College.new
    authorize @college
    @college.build_address
  end

  # GET /colleges/1/edit
  def edit
    @college = College.find(params[:id])
    authorize @college

    @college.build_address unless @college.address
  end

  # POST /colleges
  # POST /colleges.json
  def create
    @college = College.new(college_params)
    authorize @college

    if @college.save
      redirect_to @college, notice: 'College was successfully created.'
    else
      render :new
    end
  end

  # PUT /colleges/1
  # PUT /colleges/1.json
  def update
    @college = College.find(params[:id])
    authorize @college

    if @college.update_attributes(college_params)
      redirect_to @college, notice: 'College was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @college = College.find(params[:id])
    authorize @college
    @college.destroy
  end

  private

  def college_params
    params.require(:college)
          .permit(:name, address_attributes: %i[id line1 line2 city state zip])
  end
end
