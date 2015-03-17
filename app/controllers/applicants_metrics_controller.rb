class ApplicantsMetricsController < ApplicationController
  def index
    @data = DashboardMetrics.new.generate
  end
end
