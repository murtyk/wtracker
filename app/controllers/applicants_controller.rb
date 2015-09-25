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
    if params[:query]
      @applicant_metrics = ApplicantMetrics.new
      @applicant_metrics.query(params[:query])
      render 'index_from_metrics'
      return
    end

    @applicants  = search_applicants

    return unless @applicants.any?

    unless request.format.xls?
      @applicants  = @applicants.paginate(page: params[:page], per_page: 20)
    end

    @applicants = @applicants.decorate
  end

  # GET /applicants/1
  def show
  end

  # GET /applicants/new
  def new
    @applicant = Applicant.new
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

  # Only allow a trusted parameter "white list" through.
  def applicant_params
    params.require(:applicant)
      .permit(:salt, :reapply_key, :first_name, :last_name,
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

  def search_applicants
    navigator_id,
    status,
    edp,
    assessments,
    in_klass     = search_filters

    return [] unless navigator_id || status

    applicants = Applicant
                 .includes(:county, :sector)
                 .includes(trainee: [:assessments, :klasses, :unemployment_proof_file])
                 .where(predicate(navigator_id, status))
                 .order(created_at: :desc)
    return applicants unless edp || assessments || in_klass

    apply_filters(applicants, edp, assessments, in_klass)
  end

  def predicate(navigator_id, status)
    pred = {}
    pred.merge!(navigator_id: navigator_id) unless navigator_id.blank?
    pred.merge!(status: status) unless status.blank?
    pred
  end

  def apply_filters(applicants, edp, assessments, in_klass)
    applicants = applicants.where.not(trainees: { edp_date: nil }) if edp

    if assessments
      trainee_ids = Trainee.with_assessments.pluck(:id)
      applicants = applicants.where(trainee_id: trainee_ids)
    end

    if in_klass
      trainee_ids = Trainee.in_klass.pluck(:id)
      applicants = applicants.where(trainee_id: trainee_ids)
    end

    applicants
  end

  def search_filters
    @filter_info = params[:filters] || {}
    [
      @filter_info[:navigator_id],
      @filter_info[:status],
      @filter_info[:edp].to_i > 0,
      @filter_info[:assessments].to_i > 0,
      @filter_info[:in_klass].to_i > 0
    ]
  end

  def next_applicant
    return @applicant unless current_user && current_user.navigator?
    id = @applicant.id
    nav_applicants = Applicant.where(status: 'Accepted', navigator_id: current_user.id)
    nav_applicants.where('id > ?', id).order(:id).first || nav_applicants.order(:id).first
  end
end
