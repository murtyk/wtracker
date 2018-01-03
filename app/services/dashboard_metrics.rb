# Root class for any grant sepecific dashboard metrics
class DashboardMetrics
  attr_accessor :template
  def self.generate(grant, params)
    # for applicants grant, show job leads metrics instead of dashboard
    #    when job leads metrics menu selected
    return AutoLeadsMetrics.new(params) if params[:auto_leads_metrics]

    return grant.dashboard.constantize.new if grant.dashboard

    return DashboardRtw.new.generate if grant.trainee_applications?
    return AutoLeadsMetrics.new(params) if grant.auto_job_leads?
    StandardMetrics.new
  end
end
