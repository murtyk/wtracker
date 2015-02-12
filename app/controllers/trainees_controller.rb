class TraineesController < ApplicationController
  before_action :authenticate_user!, except: [:portal, :edit, :update]
  before_filter :authenticate_trainee!, only: [:portal]
  before_action :user_or_trainee, only: [:edit, :update]
  before_action :set_trainee_grant

  def search_by_skills
    @results      = []
    @filter_info  =  {}

    return unless params[:filters]

    @filter_info  = params[:filters]
    skills        = @filter_info[:skills]
    @results      = TraineeSearchService.search_by_skills(skills)
    unless @results.blank?
      trainee_ids   = @results.map { |result| result.trainee.id }
      trainee_names = @results.map { |result| result.trainee.name }
      @trainee_email = current_user.trainee_emails.new(trainee_ids: trainee_ids,
                                                       trainee_names: trainee_names,
                                                       klass_id: 0)
    end
  end

  def docs_for_selection
    klass_id = params[:klass_id].to_i
    @trainees = Trainee.includes(:trainee_files)
                       .joins(:klass_trainees)
                       .where(klass_trainees: { klass_id: klass_id })
  end

  def advanced_search
    @q = Trainee.ransack(params[:q])
    # @trainees = @q.result(distinct: true)
    @trainees = @q.result.includes(:klasses, :job_search_profile, :assessments,
                                   :funding_source, :home_address, :tact_three)
                         .includes(applicant: [:applicant_reapplies, :navigator])
  end

  def index
    @trainees     = []
    @filter_info  =  {}

    return unless params[:filters]

    @filter_info  = params[:filters]
    last_name     = @filter_info[:last_name]
    klass_id      = @filter_info[:klass_id].to_i

    return if klass_id == 0 && last_name.blank?

    trainees = Klass.find(klass_id).trainees if last_name.blank?
    trainees = Trainee.where('last ilike ?', last_name + '%') unless last_name.blank?
    @trainees = trainees.order(:first, :last)
  end

  def mapview
     # debugger
    @trainees_map = TraineesMap.new(params[:filters])
  end

  def near_by_colleges
    @trainees_map = NearByCollegesMap.new(current_user)
  end

  def new
    @trainee = TraineeFactory.new_trainee
    authorize @trainee
  end

  def create
    @trainee = TraineeFactory.new_trainee(params[:trainee])
    authorize @trainee

    respond_to do |format|
      if TraineeFactory.save(@trainee)
        format.html { redirect_to @trainee, notice: 'Trainee was successfully added.' }
        format.json { render json: @trainee, status: :created, location: @trainee }
      else
        format.html { render :new }
        format.json { render json: @trainee.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @trainee = Trainee.find(params[:id])
    authorize @trainee

    TraineeFactory.build_addresses_and_tact3(@trainee)
  end

  def update
    if current_trainee
      @trainee = TraineeFactory.update_trainee_by_trainee(params)
      if @trainee.errors.empty?
        portal
      else
        render 'trainee_data_form'
      end
      return
    end

    authorize Trainee.find(params[:id])
    @trainee = TraineeFactory.update_trainee(params)
    if @trainee.errors.empty?
      redirect_to(@trainee, notice: 'Trainee was successfully updated.')
    else
      render :edit
    end
  end

  def destroy
    @trainee = Trainee.find(params[:id])
    authorize @trainee
    @trainee.destroy

    respond_to do |format|
      format.html { redirect_to trainees_url }
      format.js
      format.json { head :no_content }
    end
  end

  def show
    @trainee = Trainee.find(params[:id]).decorate
    authorize @trainee
  end

  def portal
    @trainee = Trainee.find(current_trainee.id) # avoids caching issues
    if @trainee.pending_data?
      render 'trainee_data_form'
      return
    end
    unless @trainee.job_search_profile.valid_profile?
      redirect_to edit_job_search_profile_path(@trainee.job_search_profile)
      return
    end
    if @trainee.trainee_files.empty?
      @error_message = params[:error_message]
      @trainee_file = @trainee.trainee_files.new
    elsif params[:trainee_files]
      @trainee_files = current_trainee.trainee_files.order(created_at: :desc)
      @trainee_file = @trainee.trainee_files.new
    else
      redirect_to job_search_profile_path(@trainee.job_search_profile)
      return
    end
  end

  def user_or_trainee
    redirect_to root_path unless current_user || current_trainee
  end

  def set_trainee_grant
    if current_trainee
      grant_id = current_trainee.grant_id
      session[:grant_id] = grant_id
      Grant.current_id = grant_id
    end
  end
end
