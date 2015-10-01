#
class ApplicantReappliesController < ApplicationController
  before_action :authenticate_user!, only: [:index]
  before_action :set_grant,          only: [:new, :create]

  def index
    @applicant_reapplys = ApplicantReapply
                          .includes(:applicant)
                          .where(used: true)
  end

  def new
    @applicant_reapply = current_grant.applicant_reapplies.new
  end

  def create
    @applicant_reapply = ApplicantFactory
                         .create_reapply(applicant_reapply_params,
                                         current_grant)

    return unless @applicant_reapply.errors.any?

    render 'new'
  end

  private

  def applicant_reapply_params
    params.require(:applicant_reapply)
      .permit(:email)
  end

  def set_grant
    @grant = grant_from_salt
    fail 'Not Authorized' unless @grant
    Grant.current_id = @grant.id
    session[:grant_id] = @grant.id
    return if @grant.trainee_applications?
    fail 'Can not add applicants for this grant'
  end

  def grant_from_salt
    grant_id = grant_id_from_salt

    return nil unless grant_id.to_i > 0
    Grant.where(id: grant_id).first
  end

  def grant_id_from_salt
    salt = salt_from_params
    salt && salt.delete('^0-9').to_i
  end

  def salt_from_params
    params[:salt] ||
      (params[:applicant_reapply] && params[:applicant_reapply][:salt])
  end
end
