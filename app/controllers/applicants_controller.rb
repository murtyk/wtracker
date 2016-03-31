# Applicant registration and analysis
class ApplicantsController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show, :analysis]
  before_action :set_grant,          only: [:new, :create, :edit]
  before_action :set_applicant,      only: [:show, :edit, :update]
  before_action :user_or_key,        only: [:update]

  def analysis
    am = ApplicantMetrics.new(current_user)
    @metrics = am.generate_analysis
  end

  # GET /applicants
  def index
    return show_metrics if params[:query]

    @as = ApplicantSearch.new(current_user)

    respond_to do |format|
      format.html { perform_search }
      format.js  { send_search_results_file_by_email }
      format.xls { send_search_results_file }
    end
  end

  # GET /applicants/1
  def show
  end

  # GET /applicants/new
  def new
    @applicant = Applicant.new(new_applicant_params)
    @applicant.salt = @grant.id.to_s
  end

  # POST /applicants
  def create
    @applicant = ApplicantFactory.create(@grant, request, applicant_params)

    if @applicant.errors.any?
      flash[:error] = @applicant.errors[:trainee_id][0]
      render 'new'
      return
    else
      flash[:error] = nil
    end
  end

  # only applicant can reapply
  def edit
    validate_key
  end

  # PATCH/PUT /applicants/1
  def update
    @applicant = ApplicantFactory.update(params[:id], applicant_params)

    return reapply_action if params[:applicant][:reapply_key]

    return render('show') if @applicant.errors.any?

    action_after_update
  end

  private

  def show_metrics
    @applicant_metrics = ApplicantMetrics.new
    @applicant_metrics.query(params[:query])
    render 'index_from_metrics'
  end

  def action_after_update
    notice = 'Applicant updated successfully'
    applicant = next_applicant
    redirect_to(applicant, notice: notice) if applicant
    redirect_to('/applicants/analysis', notice: notice) unless applicant
  end

  def reapply_action
    return render('new') if @applicant.errors.any?
    render 'create'
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_applicant
    @applicant = Applicant.find(params[:id])
  end

  def new_applicant_params
    return {} unless params[:employment_status]
    { current_employment_status: params[:employment_status] }
  end

  # Only allow a trusted parameter "white list" through.
  def applicant_params
    params.require(:applicant)
      .permit(:salt, :reapply_key, :first_name, :last_name, :unique_id,
              :address_line1, :address_line2, :address_city, :address_state,
              :address_zip, :county_id, :email,
              :mobile_phone_no, :last_employed_on, :current_employment_status,
              :last_job_title, :salary_expected, :education_level,
              :transportation, :computer_access, :comments, :status, :navigator_id,
              :legal_status, :veteran, :sector_id,
              :last_employer_name, :last_employer_city, :last_employer_state,
              :resume, :source, :signature, :humanizer_answer,
              :humanizer_question_id, :email_confirmation,
              :gender, :race_id, :last_wages, :last_employer_line1,
              :last_employer_line2, :last_employer_zip, :last_employer_manager_name,
              :last_employer_manager_phone_no, :last_employer_manager_email,
              :unemployment_proof, :skills, :dob, special_service_ids: [],
                                                  trainee: [:funding_source_id])
  end

  def salt_from_params
    params[:salt] || (params[:applicant] && params[:applicant][:salt])
  end

  def set_grant
    @grant = grant_from_salt(salt_from_params)
    fail 'Not Authorized' unless @grant
    Grant.current_id = @grant.id
    session[:grant_id] = @grant.id
    fail 'Can not add applicants for this grant' unless @grant.trainee_applications?
  end

  def grant_from_salt(salt)
    return nil unless salt
    grant_id = grant_id_from_salt(salt)
    return nil if grant_id == 0
    Grant.where(id: grant_id).first
  end

  def grant_id_from_salt(salt)
    salt.delete('^0-9').to_i
  end

  def validate_key
    fail 'invalid key or expired link' unless @applicant.reapply_key == param_key
  end

  def user_or_key
    return true if current_user
    validate_key
  end

  def param_key
    params[:key] || (params[:applicant] && params[:applicant][:reapply_key])
  end

  def send_search_results_file
    @as.build_document(search_params)
    send_file @as.file_path, type: 'application/vnd.ms-excel',
                             filename: @as.file_name,
                             stream: false
  end

  def send_search_results_file_by_email
    @as.delay.send_results(search_params)
    Rails.logger.info "#{current_user.name} has requested Applicant Search file by email"
  end

  def perform_search
    @applicants = @as.perform(search_params)
    return unless @applicants.any?
    @applicants = @applicants.paginate(page: params[:page], per_page: 20).decorate
  end

  def search_params
    unless params[:filters]
      @filter_info = {}
      return @filter_info
    end
    @filter_info ||= params.require(:filters)
                     .permit(:name,
                             :navigator_id,
                             :status,
                             :funding_source_id,
                             :edp,
                             :assessments,
                             :in_klass)
  end

  def next_applicant
    return @applicant unless current_user && current_user.navigator?
    id = @applicant.id
    nav_applicants = Applicant.where(status: 'Accepted', navigator_id: current_user.id)
    nav_applicants.where('id > ?', id).order(:id).first || nav_applicants.order(:id).first
  end
end
