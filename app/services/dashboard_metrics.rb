# dashboard metrics for grants where applicants can apply
class DashboardMetrics
  # need this for link_to
  include ActionView::Helpers::UrlHelper
  attr_reader :metrics

  def initialize
    @metrics = OpenStruct.new
    @metrics.rows = []
  end

  # generates for dashboard data where grant accepts applicants
  def generate
    @tsm = TraineeStatusMetrics.new
    @tsm.generate
    generate_header
    @metrics.rows << row_zero
    generate_metrics
    @metrics
  end

  private

  # blank, no of trainees, FS1, FS2,..., TS1, TS2, ...
  def generate_header
    @metrics.header = ['', '# Trainees'] + fs_names + @tsm.metrics.headers
  end

  # a row is for a navigator
  # name, # trainees, trainees with fs1, trainees with fs2,.. trainees with status1, ...
  def generate_metrics
    @tsm.metrics.rows.each do |ts_row|
      id, name = ts_row.shift
      row = [name]
      trainees = Trainee.joins(:applicant).where(applicants: { navigator_id: id })
      row << trainees.count
      fs_counts = trainees.group(:funding_source_id).count
      funding_sources.keys.each do |fs_id|
        count = fs_counts[fs_id].to_i
        if fs_id
          row << link(count, applicant_navigator_id_eq: id, funding_source_id_eq: fs_id)
        else
          row << link(count, applicant_navigator_id_eq: id, funding_source_id_null: 1)
        end
      end
      row += ts_row
      @metrics.rows << row
    end
  end

  # Totals, # of trainees, fs1, fs2, ...., ts1, ts2, ...
  def row_zero
    row = ['Totals', link(Trainee.count, {})]
    fs_counts = Trainee.group(:funding_source_id).count
    funding_sources.keys.each do |id|
      if id
        row << link(fs_counts[id],  funding_source_id_eq: id)
      else
        row << link(fs_counts[id],  funding_source_id_null: 1)
      end
    end
    ts_counts = Trainee.group(:gts_id).count
    @tsm.status_ids.each do |status_id|
      count = ts_counts[status_id].to_i
      row << link(count, gts_id_eq: status_id)
    end
    row
  end

  def fs_names
    funding_sources.values
  end

  # returns fundings sources as hash id => name
  # since some trainees may not have fs assigned includes nil => 'N/A'
  def funding_sources
    return @funding_sources if @funding_sources
    @funding_sources = Hash[*FundingSource.order(:name).pluck(:id, :name).flatten]
    if Trainee.where(funding_source_id: nil).any?
      @funding_sources[nil] = 'FS N/A'
    end
    @funding_sources
  end

  def link(count, params)
    link_to(count, href(params))
  end

  def href(params = {})
    url_helpers.advanced_search_trainees_path(q: params)
  end

  # need this for href
  def url_helpers
    Rails.application.routes.url_helpers
  end
end
