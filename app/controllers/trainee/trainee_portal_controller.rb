# frozen_string_literal: true

class Trainee
  # Trainee Signed In
  # Base controller for all controllers in Trainee namespace
  class TraineePortalController < ApplicationController
    before_action :authenticate_trainee!
    before_action :init_data

    def perform_portal_action
      case @trainee_portal.action
      when :closed
        sign_out @trainee
        render 'closed', layout: false
      when :pending_data
        render 'edit'
      when :pending_resume
        redirect_to_new_file('Resume')
      when :pending_unemployment_proof
        redirect_to_new_file('Unemployment Proof')
      when :pending_profile
        redirect_to edit_trainee_job_search_profile_path(@job_search_profile)
      when :jobs
        redirect_to trainee_job_search_profile_path(@job_search_profile)
      end
    end

    def redirect_to_new_file(notes)
      redirect_to new_trainee_trainee_file_path(notes: notes)
    end

    def init_data
      @trainee = current_trainee
      @trainee_portal     = TraineePortal.new(current_trainee)
      @trainee_menu_bar   = @trainee_portal.show_menu_bar?
      @job_search_profile = @trainee.job_search_profile
    end
  end
end
