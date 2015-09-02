class ImportStatusesController < ApplicationController
  before_filter :authenticate_user!

  def new
    resource = params[:resource]
    render "new_#{resource}" unless params[:updates]
    render "update_#{resource}" if params[:updates]
  end

  def create
    @importer = Importer.new_importer(params, current_user)
    return if @importer.errors?

    Delayed::Job.enqueue CustomJob.new(current_account)
    @importer.delay.import
  end

  def show
    @import_status = ImportStatus.find(params[:id])
    render @import_status.template_name
  end

  def status
    import_status = ImportStatus.find(params[:id])
    data = {
      status: import_status.status,
      rows_failed: import_status.rows_failed || 0,
      rows_successful: import_status.rows_successful || 0
    }
    respond_to do |format|
      format.json { render json: data }
    end
  end

  def retry
    @import_fail = ImportFail.find(params[:import_fail_id])
    @import_fail.retry
  end
end
