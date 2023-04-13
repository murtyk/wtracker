# frozen_string_literal: true

class GrantsController < ApplicationController
  before_action :authenticate_user!

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
      else
        format.html { render :edit }
      end
      format.js
    end
  end

  def password_message
    @grant = current_grant
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
                  :unemployment_proof_text,
                  :email_password_subject, :email_password_body,
                  :assessments_include_score, :assessments_include_pass)
  end

  def update_notice
    return 'Re-apply email message updated.' if params[:grant][:reapply_subject]

    'Grant was successfully updated.'
  end
end
