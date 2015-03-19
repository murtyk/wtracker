class ProgramsController < ApplicationController
  before_filter :authenticate_user!

  # GET /programs
  def index
    @programs = Program.all
  end

  # GET /programs/1
  def show
    @program = Program.find(params[:id])
    authorize @program
  end

  # GET /programs/new
  def new
    @program = Program.new
    authorize @program
  end

  # GET /programs/1/edit
  def edit
    @program = Program.find(params[:id])
    authorize @program
  end

  # POST /programs
  def create
    @program = Program.new(params[:program])
    authorize @program

    if @program.save
      redirect_to @program, notice: 'Program was successfully created.'
    else
      render :new
    end
  end

  # PUT /programs/1
  def update
    @program = Program.find(params[:id])
    authorize @program

    if @program.update_attributes(params[:program])
      redirect_to @program, notice: 'Program was successfully updated.'
    else
      render :edit
    end
  end
end
