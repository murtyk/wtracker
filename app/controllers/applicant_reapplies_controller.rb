class ApplicantReappliesController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  before_action :set_grant,          only: [:new, :create]

  def index
  end

  def new
    @applicant_reapply      = ApplicantReapply.new
    @applicant_reapply.salt = @grant.id.to_s
  end

  def create
    email     = params[:applicant_reapply][:email]
    @applicant = Applicant.find_by('email ilike ?', email)

    if @applicant && @applicant.declined?
      @applicant_reapply = ApplicantFactory.create_reapply(@applicant)
      flash[:error] = nil
    else
      @applicant_reapply = ApplicantReapply.new
      @applicant_reapply.email = email
      @applicant_reapply.salt  = @grant.id.to_s
      if @applicant
        flash[:error] = 'You are already accepted and should have received an e-mail.'
      else
        flash[:error] = 'Email Not found. Please enter correct email address.'
      end
      render 'new'
    end
  end

  private

  def set_grant
    salt = params[:salt] ||
           (params[:applicant_reapply] && params[:applicant_reapply][:salt])
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
end
