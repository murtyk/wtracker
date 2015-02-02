class EmployersController < ApplicationController
  # before_filter :authenticate_user!, except: [:list_for_trainee]
  before_filter :user_and_no_trainee, except: [:list_for_trainee]
  before_action :user_or_trainee, only: [:list_for_trainee]

  def add_google_company
    # debugger

    @employer,
    @employer_exists,
    @error = EmployerFactory.create_from_job_search(current_user, params)

    @action_cell_id = '#' + params[:action_cell_id]
    @add_company_id = '#' + params[:add_company_id]
  end

  def get_google_company
    # debugger unless params[:name_location]
    name, location, _city_id = params[:name_location].split('::')
    company = Company.new(name, location)
    company.search
    render json: { found: company.found }
  end

  def search_google
    @companies = CompanyFinder.google_search(params[:filters]) if params[:filters]
  end

  def list_for_trainee
    employers = EmployerServices.new(params).employers_for_trainee_interaction
    respond_to do |format|
      format.json { render json: employers }
    end
  end

  def search
    employers = EmployerServices.new(params[:filters]).search

    respond_to do |format|
      format.json { render json: employers }
    end
  end

  def contacts_search
    contacts = EmployerServices.new(params[:filters]).search_contacts
    respond_to do |format|
      format.json { render json: contacts }
    end
  end

  # GET /employers
  # GET /employers.json
  def index
    @employers = EmployerServices.new(params[:filters]).search
    @employers_count = @employers.count
    unless request.format.xls?
      @employers = @employers.to_a.paginate(page: params[:page], per_page: 20)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xls # index.xls.erb
    end
  end

  def mapview
    @employer_map = EmployersMap.new(params[:filters])
  end

  def analysis
    @analysis = employer_analysis
  end

  # GET /employers/1
  # GET /employers/1.json
  def show
    @employer = Employer.find(params[:id]).decorate
    authorize @employer

    # debugger
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @employer }
    end
  end

  # GET /employers/new
  # GET /employers/new.json
  def new
    @employer = Employer.new
    logger.info { "[#{current_user.name}] [employer new]" }
    authorize @employer
    @employer.build_address

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @employer }
    end
  end

  # GET /employers/1/edit
  def edit
    @employer = Employer.find(params[:id])
    @employer.build_address unless @employer.address
    authorize @employer
  end

  # POST /employers
  # POST /employers.json
  def create
    # debugger

    authorize Employer.new

    @employer, saved = EmployerFactory.create_employer(current_user, params[:employer])

    respond_to do |format|
      if saved
        notice = 'Employer was successfully created.'
        format.html { redirect_to @employer, notice: notice }
        format.js
      else
        format.html { render :new }
        format.js
      end
    end
  end

  # PUT /employers/1
  # PUT /employers/1.json
  def update
    authorize Employer.find(params[:id])

    saved, @employer, error_message = EmployerFactory.update_employer(params)

    respond_to do |format|
      if saved
        notice = 'Employer was successfully updated.'
        format.html { redirect_to @employer, notice: notice }
      else
        flash[:error] = error_message
        format.html { render :edit }
      end
    end
  end

  # DELETE /employers/1
  # DELETE /employers/1.json
  def destroy
    @employer = Employer.find(params[:id])
    authorize @employer

    @employer.destroy

    respond_to do |format|
      format.html { redirect_to employers_url }
      format.js
      format.json { head :no_content }
    end
  end
end
