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

    if @grant.update_attributes(params[:grant])
      redirect_to @grant, notice: update_notice
    else
      render :edit
    end
  end

  def reapply_message
    @grant = current_grant
  end

  def hot_jobs_notify_message
    @grant = current_grant
  end

  def update_notice
    return 'Re-apply email message updated.' if params[:grant][:reapply_subject]
    'Grant was successfully updated.'
  end
end
