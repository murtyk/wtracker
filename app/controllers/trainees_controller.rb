# Trainee is also known as student, candidate, applicant
# there is a seperate model for Applicant
class TraineesController < ApplicationController
  before_action :authenticate_user!

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
    @tas = TraineeAdvancedSearch.new(current_user)

    respond_to do |format|
      format.html { perform_advanced_search }
      format.js { @tas.delay.send_results(params[:q]) }
      format.xls { send_advanced_search_results_file }
    end
  end

  def index
    @filter_info  = params[:filters] || {}
    @trainees = TraineeSearchService.search(current_user, params)
  end

  def mapview
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

  def send_advanced_search_results_file
    @tas.build_document(params[:q])
    send_file @tas.file_path, type: 'application/vnd.ms-excel',
                              filename: @tas.file_name,
                              stream: false
  end

  def perform_advanced_search
    @trainees = @tas.search(params[:q])
    @q = @tas.q
    @trainees = @trainees.to_a.paginate(page: params[:page], per_page: 20)
  end
end
