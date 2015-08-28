class ApplicantReappliesController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  before_action :set_grant,          only: [:new, :create]

  def index
  end

  def new
    @applicant_reapply = current_grant.applicant_reapplies.new
  end

  def create
    @applicant_reapply = ApplicantFactory
                         .create_reapply(applicant_reapply_params,
                                         current_grant)

    if @applicant_reapply.errors.any?
      render 'new'
      return
    end
  end

  private

  def applicant_reapply_params
    params.require(:applicant_reapply)
      .permit(:email)
  end

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
