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
    @filter_info = params[:filters] || {}
    @applicants  = search_applicants(@filter_info)
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
    @applicant = ApplicantFactory.update(params)

    if @applicant.errors.empty?
      if params[:applicant][:reapply_key]
        render 'create'
        return
      end
      notice = 'Applicant updated successfully'
      next_applicant = @applicant.next
      redirect_to(next_applicant, notice: notice) if next_applicant
      redirect_to('/applicants/analysis', notice: notice) unless next_applicant
    else
      if params[:applicant][:reapply_key]
        render 'new'
      else
        render 'show'
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_applicant
    @applicant = Applicant.find(params[:id])
  end

    # Only allow a trusted parameter "white list" through.
  def applicant_params
    params.require(:applicant)
          .permit(:salt, :first_name, :last_name, :address_line1, :address_line2,
                  :address_city, :address_state, :address_zip, :county_id, :email,
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
                  :unemployment_proof, special_service_ids: []
                  )
  end

  def set_grant
    salt = params[:salt] || (params[:applicant] && params[:applicant][:salt])
    @grant = grant_from_salt(salt)
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

  def search_applicants(filters)
    navigator_id = filters[:navigator_id]
    status       = filters[:status]

    return [] unless navigator_id || status

    predicate = {}
    predicate.merge!(navigator_id: navigator_id) unless navigator_id.blank?
    predicate.merge!(status: status) unless status.blank?
    Applicant.where(predicate).order(created_at: :desc)
  end
end
