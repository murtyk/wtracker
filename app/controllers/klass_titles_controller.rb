class KlassTitlesController < ApplicationController
  before_filter :authenticate_user!

  def job_search_count
    # puts "account id set to " + Account.current_id.to_s

    klass_title = KlassTitle.find(params[:id])

    job_search = klass_title.get_job_search

    respond_to do |format|
      format.json { render json: job_search.count }
    end
  end

  # GET /klass_titles/new
  # GET /klass_titles/new.json
  def new
    klass = Klass.find(params[:klass_id])
    @klass_title = klass.klass_titles.build

    respond_to do |format|
      format.js
      format.json { render json: @klass_title }
    end
  end

  # POST /klass_titles
  # POST /klass_titles.json
  def create
    @klass_title = KlassTitle.new(params[:klass_title])
    @klass_title.save
  end

  # DELETE /klass_titles/1
  # DELETE /klass_titles/1.json
  def destroy
    @klass_title = KlassTitle.find(params[:id])
    @klass_title.destroy

    respond_to do |format|
      format.js
      format.json { head :no_content }
    end
  end
end
