class ProgramsController < ApplicationController
  before_filter :authenticate_user!

  TRAINEE_STATUS_TEMPLATES = { PENDING:     'trainees_pending_job_search_profile',
                               NOT_PENDING: 'trainees_updated_job_search_profile',
                               VIEWED:      'trainees_viewed_auto_leads',
                               NOT_VIEWED:  'trainees_not_viewed_auto_leads',
                               APPLIED:     'trainees_applied_auto_leads',
                               NOT_APPLIED: 'trainees_not_applied_auto_leads',
                               OPTED_OUT:   'trainees_opted_out'
                              }

  def trainees_by_auto_lead_status
    @program = Program.find(params[:id])
    alt         = AutoLeadTrainees.new
    alt.program = @program
    @trainees   = alt.by_status(params[:status])

    @job_search_profiles_map = JobSearchProfilesMap.new(@trainees) if params[:map]
    render template
  end

  # GET /programs
  # GET /programs.json
  def index
    @programs = Program.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: Program.all }
    end
  end

  # GET /programs/1
  # GET /programs/1.json
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
  # POST /programs.json
  def create
    @program = Program.new(params[:program])
    authorize @program

    respond_to do |format|
      if @program.save
        format.html { redirect_to @program, notice: 'Program was successfully created.' }
        # format.json { render json: @program, status: :created, location: @program }
      else
        format.html { render :new }
        # format.json { render json: @program.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /programs/1
  # PUT /programs/1.json
  def update
    @program = Program.find(params[:id])
    authorize @program

    respond_to do |format|
      if @program.update_attributes(params[:program])
        format.html { redirect_to @program, notice: 'Program was successfully updated.' }
        # format.json { head :no_content }
      else
        format.html { render :edit }
        # format.json { render json: @program.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def template
    TRAINEE_STATUS_TEMPLATES[params[:status].to_sym] + (params[:map] && '_map').to_s
  end
end
