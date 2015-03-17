class AutoLeadsMetricsController < ApplicationController
  before_filter :authenticate_user!

  def index
    return skill_metrics if params[:skill_metrics]

    @data = AutoLeadTrainees.new
    return unless params[:status]

    @trainees   = @data.by_status(params[:status])
    return show_map if params[:map]

    render @data.template
  end

  private

  def skill_metrics
    @skill_metrics = SkillMetrics.new
    @skill_metrics.generate
    render 'skill_metrics'
  end

  def show_map
    @job_search_profiles_map = JobSearchProfilesMap.new(@trainees)
    render (@data.template + '_map')
  end
end
