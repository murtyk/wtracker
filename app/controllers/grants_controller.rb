class GrantsController < ApplicationController
  before_filter :authenticate_user!

  # GET /grants
  def index
    @grants = current_user.active_grants.decorate
  end

  # GET /grants/1
  def show
    @grant = Grant.find(params[:id]).decorate
    authorize @grant
  end

  # GET /grants/1/edit
  def edit
    @grant = Grant.find(params[:id])
    authorize @grant
  end

  # PUT /grants/1
  def update
    @grant = Grant.find(params[:id])
    authorize @grant

    respond_to do |format|
      if @grant.update_attributes(grant_params)
        format.html { redirect_to @grant, notice: update_notice }
        format.js
      else
        format.html { render :edit }
        format.js
      end
    end
  end

  def reapply_message
    @grant = current_grant
  end

  def hot_jobs_notify_message
    @grant = current_grant
  end

  private

  def grant_params
    params.require(:grant)
      .permit(:name, :spots, :amount, :reply_to_email,
              :reapply_subject, :reapply_body,
              :reapply_instructions, :reapply_email_not_found_message,
              :reapply_already_accepted_message, :reapply_confirmation_message,
              :hot_jobs_notification_subject, :hot_jobs_notification_body,
              :unemployment_proof_text)
  end

  def update_notice
    return 'Re-apply email message updated.' if params[:grant][:reapply_subject]
    'Grant was successfully updated.'
  end
end
