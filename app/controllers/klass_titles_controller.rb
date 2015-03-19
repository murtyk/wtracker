class KlassTitlesController < ApplicationController
  before_filter :authenticate_user!

  def job_search_count
    klass_title = KlassTitle.find(params[:id])

    job_search = klass_title.get_job_search

    render json: job_search.count
  end

  def new
    klass = Klass.find(params[:klass_id])
    @klass_title = klass.klass_titles.build
  end

  def create
    @klass_title = KlassTitle.new(params[:klass_title])
    @klass_title.save
  end

  def destroy
    @klass_title = KlassTitle.find(params[:id])
    @klass_title.destroy
  end
end
