class GrantsController < ApplicationController
  before_filter :authenticate_user!

  # GET /grants
  # GET /grants.json
  def index
    @grants = current_user.active_grants.decorate
    # debugger

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @grants }
    end
  end

  # GET /grants/1
  # GET /grants/1.json
  def show
    @grant = Grant.find(params[:id]).decorate
    authorize @grant

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @grant }
    end
  end

  # GET /grants/1/edit
  def edit
    @grant = Grant.find(params[:id])
    authorize @grant
  end

  # PUT /grants/1
  # PUT /grants/1.json
  def update
    @grant = Grant.find(params[:id])
    authorize @grant

    respond_to do |format|
      if @grant.update_attributes(params[:grant])
        if params[:grant][:reapply_subject]
          notice = 'Re-apply email message updated.'
        else
          notice = 'Grant was successfully updated.'
        end
        format.html { redirect_to @grant, notice: notice }
        format.json { head :no_content }
      else
        format.html { render :edit }
        format.json { render json: @grant.errors, status: :unprocessable_entity }
      end
    end
  end

  def skill_metrics
    @skill_metrics = SkillMetrics.new
    @skill_metrics.generate
  end

  def reapply_message
    @grant = current_grant
  end
end
