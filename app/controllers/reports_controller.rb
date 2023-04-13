# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :authenticate_user!

  def new
    @report = Report.new_report(current_user, params)
    render @report.template
  end

  def create
    @report = Report.create(current_user, params[:report])
    respond_to do |format|
      format.html { render @report.template }
      format.js
      format.json { render json: @report.status }
    end
  end

  def show
    if request.format.html?
      @report = Report.new_report(current_user, params)
    else
      rd = ReportData.new(current_user.id, params)
    end

    respond_to do |format|
      format.html { render @report.template }
      format.js   { rd.delay.send_to_user }
      format.xls  { send_excel_file rd.excel_file }
    end
  end

  def by_email
    rd = ReportData.new(current_user.id, params)
    rd.delay.send_to_user
    report_name = params[:report][:report_name]
    Rails.logger.info "#{current_user.name} requested #{report_name} by email"
  end

  def process_next
    report = Report.new_report(current_user, params)
    status = report.process_next
    render json: status
  end

  def send_excel_file(ef)
    send_file ef.file_path, type: 'application/vnd.ms-excel',
                            filename: ef.file_name,
                            stream: false
  end
end
