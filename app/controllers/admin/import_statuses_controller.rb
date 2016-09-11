class Admin
  # for opero admin to view and clean up the imports done by users
  class ImportStatusesController < ApplicationController
    before_filter :authenticate_admin!

    def new
      resource = params[:resource]
      render "new_#{resource}"
    end

    def create
      @importer = Importer.new_importer(params)
      Delayed::Job.enqueue CustomJob.new(current_account), :queue => 'daily_job'
      @importer.delay.import unless @importer.errors?
    end

    def show
      @import_status = ImportStatus.unscoped.find(params[:id])
      render @import_status.template_name
    end

    def index
      @statuses = ImportStatus.group_by_account
    end

    def status
      import_status = ImportStatus.find(params[:id])
      data = {
        status: import_status.status,
        rows_failed: import_status.rows_failed,
        rows_successful: import_status.rows_successful
      }
      respond_to do |format|
        format.json { render json: data }
      end
    end

    def destroy
      @import_status = ImportStatus.unscoped.find(params[:id])

      @import_status.destroy

      respond_to do |format|
        format.js
        format.json { head :no_content }
      end
    end
  end
end
