class ReportsController < ApplicationController
  before_filter :authenticate_user!

  def new
    @report = Report.new_report(current_user, params)
    render @report.template
  end

  def create
    @report = Report.create(current_user, params)
    respond_to do |format|
      format.html { render @report.template }
      format.js
      format.json { render json: @report.status }
    end
  end

  def show
    @report = Report.new_report(current_user, params)
    render @report.template
  end

  def process_next
    report = Report.new_report(current_user, params)
    status = report.process_next
    render json: status
  end
end
