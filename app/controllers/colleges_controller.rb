class CollegesController < ApplicationController
  before_filter :authenticate_user!
  # GET /colleges
  # GET /colleges.json
  def index
    @colleges_map = CollegesMap.new
  end

  # GET /colleges/1
  # GET /colleges/1.json
  def show
    @college = College.find(params[:id])
    authorize @college

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @college }
    end
  end

  # GET /colleges/new
  # GET /colleges/new.json
  def new
    @college = College.new
    authorize @college
    @college.build_address

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @college }
    end
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

    respond_to do |format|
      if @college.save
        format.html { redirect_to @college, notice: 'College was successfully created.' }
        format.json { render json: @college, status: :created, location: @college }
      else
        format.html { render :new }
        format.json { render json: @college.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /colleges/1
  # PUT /colleges/1.json
  def update
    @college = College.find(params[:id])
    authorize @college

    respond_to do |format|
      if @college.update_attributes(params[:college])
        format.html { redirect_to @college, notice: 'College was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :edit }
        format.json { render json: @college.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @college = College.find(params[:id])
    authorize @college
    @college.destroy
  end
end
