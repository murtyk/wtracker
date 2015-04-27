class ApplicantsMetricsController < ApplicationController
  def index
    @data = DashboardRtw.new.generate
  end
end
