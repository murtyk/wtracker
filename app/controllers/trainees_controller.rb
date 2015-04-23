# Trainee is also known as student, candidate, applicant
# there is a seperate model for Applicant
# for some grants, trainee can sign in
class TraineesController < ApplicationController
  before_action :authenticate_user!, except: [:portal, :edit, :update]
  before_filter :authenticate_trainee!, only: [:portal]
  before_action :user_or_trainee, only: [:edit, :update]
  before_action :set_trainee_grant

  def search_by_skills
    @results      = []
    @filter_info  =  params[:filters] || {}

    return unless params[:filters]

    @results,
    @trainee_email = TraineeSearchService.search_by_skills(@filter_info[:skills],
                                                           current_user)
  end

  def docs_for_selection
    klass_id = params[:klass_id].to_i
    @trainees = Trainee.includes(:trainee_files)
                .joins(:klass_trainees)
                .where(klass_trainees: { klass_id: klass_id })
  end

  def advanced_search
    trainees = current_user.trainees_for_search(params)

    @q = trainees.ransack(params[:q])
    @trainees = search_by_grant_type

    return if request.format.xls?

    assign_trainees_count
    paginate
  end

  def index
    @filter_info  = params[:filters] || {}
    @trainees = TraineeSearchService.search(current_user, params)
  end

  def mapview
    # debugger
    @trainees_map = TraineesMap.new(current_user, params[:filters])
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
      else
        format.html { render :new }
      end
    end
  end

  def edit
    @trainee = Trainee.find(params[:id])
    authorize @trainee

    TraineeFactory.build_addresses_and_tact3(@trainee)
  end

  def update
    return update_by_trainee if current_trainee

    authorize Trainee.find(params[:id])
    @trainee = TraineeFactory.update_trainee(params)
    if @trainee.errors.empty?
      redirect_to(@trainee, notice: 'Trainee was successfully updated.')
    else
      render :edit
    end
  end

  def update_by_trainee
    @trainee = TraineeFactory.update_trainee_by_trainee(params)
    if @trainee.errors.empty?
      portal
    else
      render 'trainee_data_form'
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
    return unless current_trainee
    grant_id = current_trainee.grant_id
    session[:grant_id] = grant_id
    Grant.current_id = grant_id
  end

  def search_by_grant_type
    if current_grant.trainee_applications?
      return @q.result.includes(:klasses, :job_search_profile, :assessments,
                                :funding_source, :home_address,
                                tact_three: [:education],
                                applicant: [:navigator, :sector])
    end
    @q.result.includes(:klasses, :funding_source, :home_address,
                       :assessments, tact_three: [:education])
  end

  def assign_trainees_count
    @trainees_count = @trainees.count
  end

  def paginate
    @trainees = @trainees.to_a.paginate(page: params[:page], per_page: 20)
  end
end
