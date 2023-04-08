# frozen_string_literal: true

class Admin
  # For admin to view all trainees
  class TraineesController < ApplicationController
    before_filter :authenticate_admin!

    def index
      init_filters
      @trainees = find_trainees
    end

    def bounce
      @trainee = Trainee.unscoped.find(params[:id])
    end

    def update_bounce
      @trainee = Trainee.unscoped.find(params[:id])
      @trainee.update(
        bounced: true,
        bounced_reason: params[:trainee][:bounced_reason]
      )

      flash[:notice] = "Bounced #{@trainee.name}"
      redirect_to admin_trainees_path
    end

    private

    def init_filters
      @account_id = (params[:filters] && params[:filters][:account_id]).to_i
      @email_text = (params[:filters] && params[:filters][:email_text])
      @name_text = (params[:filters] && params[:filters][:name_text])
      @job_title = (params[:filters] && params[:filters][:job_title])
    end

    def find_trainees
      trainees = account_trainees.paginate(page: params[:page], per_page: 30)
    end

    def account_trainees
      ts = Trainee.unscoped.order(:account_id, :first, :last)
      ts = ts.where(account_id: @account_id) if @account_id.positive?
      ts = ts.where("email ilike '%#{@email_text}%'") unless @email_text.blank?

      unless @name_text.blank?
        ts = ts.where("first ilike '%#{@name_text}%' or last ilike '%#{@name_text}%'")
      end

      unless @job_title.blank?
        jobs = AutoSharedJob.where(trainee_id: ts.select(:id))
                            .where("title ilike '%#{@job_title}%'")
        t_ids = jobs.select(:trainee_id)
        ts = ts.where(id: t_ids)
      end

      ts.order(:first, :last)
    end
  end
end
