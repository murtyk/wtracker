# frozen_string_literal: true

# Opero administrator maintains grant
class Admin
  # Opero administrator maintains grant
  class GrantsController < ApplicationController
    before_filter :authenticate_admin!

    def new
      @grant = GrantFactory.new_grant(params[:account_id])
      respond_to do |format|
        format.html
        format.json { render json: @grant }
      end
    end

    def create
      @grant = GrantFactory.build_grant(grant_params)
      if @grant.errors.empty? && @grant.save
        notice = 'Grant was successfully created.'
        redirect_to(admin_grant_path(@grant), notice: notice)
      else
        render :new
      end
    end

    # GET /grants/1
    # GET /grants/1.json
    def show
      # debugger
      @grant = Grant.unscoped.find(params[:id]).decorate

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @grant }
      end
    end

    # GET /grants/1/edit
    def edit
      # debugger
      @grant = GrantFactory.find(params[:id])
    end

    # PUT /grants/1
    # PUT /grants/1.json
    def update
      @grant, notice = GrantFactory
                       .update(params[:id], grant_params.except(:account_id))
      if @grant.errors.any?
        render :edit
      else
        redirect_to [:admin, @grant], notice: notice
      end
    end

    private

    def grant_params
      return params.permit(:delete_applicant_logo) if params[:delete_applicant_logo]

      params.require(:grant)
            .permit(:account_id, :end_date, :name, :start_date, :status, :spots, :amount,
                    :auto_job_leads, :trainee_applications, :applicant_logo_file,
                    :assessments_include_score, :assessments_include_pass,
                    :reply_to_email, :reapply_subject, :reapply_body,
                    :reapply_instructions, :reapply_email_not_found_message,
                    :reapply_already_accepted_message,
                    :reapply_confirmation_message,
                    :hot_jobs_notification_subject, :hot_jobs_notification_body,
                    profile_request_subject_attributes: [:content],
                    profile_request_content_attributes: [:content],
                    job_leads_subject_attributes: [:content],
                    job_leads_content_attributes: [:content],
                    optout_message_one_attributes: [:content],
                    optout_message_two_attributes: [:content],
                    optout_message_three_attributes: [:content])
    end
  end
end
