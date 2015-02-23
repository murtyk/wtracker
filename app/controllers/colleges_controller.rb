class CollegesController < ApplicationController
  before_filter :authenticate_user!
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
    @college = College.new(params[:college])
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

    if @college.update_attributes(params[:college])
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
end
