# frozen_string_literal: true

# dashboard metrics for grants where applicants can apply.
# example grant: RTW (NJWF)
class DashboardRtw < DashboardMetrics
  # need this for link_to
  include ActionView::Helpers::UrlHelper
  attr_reader :metrics

  def initialize
    @template = 'applicants_metrics/index'
    @metrics = OpenStruct.new
    @metrics.header =
      ['ALL', '# Trainees'] +
      ['Placed', 'OJT Enrolled', 'Incumbents', 'WS', 'OCC', '# Assessed', 'EDP'] +
      fs_names

    init_metrics_for_funding_sources
  end

  # build rows for each funding source
  # rows is array of arrays. first row is totals.
  def init_metrics_for_funding_sources
    @metrics.fs_data = funding_sources.map do |id, name|
      os = OpenStruct.new
      os.id = id
      os.header = [name, '# Trainees'] +
                  ['Placed', 'OJT Enrolled', 'Incumbents', 'WS', 'OCC', '# Assessed',
                   'EDP'] +

                  # [nav name, # trainees, fs1 count..., placed, ojt enrolled, attended WS, attended OCC]
                  os.rows = []
      os
    end
  end

  # generates for dashboard data where grant accepts applicants
  def generate
    t_matrix = build_trainee_counts_matrix
    a_matrix = build_assessed_counts_matrix
    e_matrix = build_edp_counts_matrix
    p_matrix = build_placements_counts_matrix
    oe_matrix = build_ojt_enrolled_counts_matrix
    inc_matrix = build_incumbent_matrix
    ws_matrix = build_ws_counts_matrix
    occ_matrix = build_occ_counts_matrix

    build_fs_matrices(t_matrix, a_matrix, e_matrix, p_matrix, oe_matrix, inc_matrix,
                      ws_matrix, occ_matrix)
    build_summary_matrix(t_matrix, a_matrix, e_matrix, p_matrix, oe_matrix, inc_matrix,
                         ws_matrix, occ_matrix)

    self
  end

  private

  # builds all data values except totals row
  def build_summary_matrix(t_matrix, a_matrix, e_matrix, p_matrix, oe_matrix, inc_matrix, ws_matrix, occ_matrix)
    # column 0 has assessment totals by nav
    a_column = a_matrix.column(0)
    e_column = e_matrix.column(0)

    # column 0 has placement totals by trainee
    p_column = p_matrix.column(0)

    # column 0 has ojt enrollment totals by trainee
    oe_column = oe_matrix.column(0)

    inc_column = inc_matrix.column(0)

    ws_column = ws_matrix.column(0)
    occ_column = occ_matrix.column(0)

    # Trainees Placed OJT Enrolled WS OCC Assessed EDP

    # now add a, e, p and oe columns and build a new matrix
    t_matrix.insert_column(p_column, 1, nil)
    t_matrix.insert_column(oe_column, 2, nil)

    t_matrix.insert_column(inc_column, 3, nil)

    t_matrix.insert_column(ws_column, 4, nil)
    t_matrix.insert_column(occ_column, 5, nil)

    t_matrix.insert_column(a_column, 6, nil)
    t_matrix.insert_column(e_column, 7, nil)

    t_matrix.prepend_column(column_headers)

    @metrics.rows = t_matrix.data
  end

  # each of the input array matrice will have sum row and sum columns
  # the element data starts from 1,1
  # for each fs, take the corresponding columns from each of the input matrix
  def build_fs_matrices(t_matrix, a_matrix, e_matrix, p_matrix, oe_matrix, inc_matrix, ws_matrix, occ_matrix)
    (0..funding_sources.count - 1).each do |i|
      trainees     = t_matrix.column(i + 1)
      assessed     = a_matrix.column(i + 1)
      edp          = e_matrix.column(i + 1)
      placed       = p_matrix.column(i + 1)
      ojt_enrolled = oe_matrix.column(i + 1)
      incumbents    = inc_matrix.column(i + 1)
      ws_attended   = ws_matrix.column(i + 1)
      occ_attended  = occ_matrix.column(i + 1)
      @metrics
        .fs_data[i]
        .rows = build_fs_rows(trainees, assessed, edp, placed, ojt_enrolled, incumbents,
                              ws_attended, occ_attended)
    end
  end

  def build_fs_rows(trainees, assessed, edp, placed, ojt_enrolled, incumbents, ws_attended, occ_attended)
    # [headers, trainees, 'Placed', 'OJT Enrolled', 'WS', 'OCC', '# Assessed', 'EDP'] +

    columns = [column_headers, trainees, placed, ojt_enrolled, incumbents, ws_attended,
               occ_attended, assessed, edp]
    columns.transpose
  end

  def column_headers
    ['Totals'] + navigator_names
  end

  # builds trainees counts matrix
  #                   FS1           FS2
  #
  #                   fs1 total      fs2 total
  #
  #  Nav1   nav1_sum  v11            v12
  #
  #  Nav2   nav2_sum  v21            v22
  #
  def build_trainee_counts_matrix
    trainee_counts = trainees_group_by_nav_and_fs # key format: [fs_id, nav_id]
    build_nav_fs_matrix(trainee_counts, method(:nav_fs_link)) # array matrix
  end

  def build_assessed_counts_matrix
    assessed_counts = assessed_group_by_nav_and_fs # key format: [fs_id, nav_id]
    # build_nav_fs_matrix(assessed_counts, method(:nav_fs_assessed_link)) # array matrix
    build_nav_fs_matrix(assessed_counts) # array matrix
  end

  def build_edp_counts_matrix
    edp_counts = edp_group_by_nav_and_fs
    build_nav_fs_matrix(edp_counts)
  end

  # builds trainee placements counts matrix
  #                   FS1           FS2
  #
  #                   fs1 total      fs2 total
  #
  #  Nav1   nav1_sum  v11            v12
  #
  #  Nav2   nav2_sum  v21            v22
  #
  def build_placements_counts_matrix
    placed_counts = placed_counts_group_by_nav_fs
    build_nav_fs_matrix(placed_counts, method(:placed_link))
  end

  def build_ojt_enrolled_counts_matrix
    enrolled_counts = ojt_enrolled_counts_group_by_nav_fs
    build_nav_fs_matrix(enrolled_counts, method(:ojt_enrolled_link))
  end

  def build_incumbent_matrix
    incumbent_counts = incumbent_counts_group_by_nav_fs
    build_nav_fs_matrix(incumbent_counts, method(:incumbent_link))
  end

  def build_ws_counts_matrix
    counts = KlassTrainee
             .joins(trainee: :applicant, klass: :klass_category)
             .where(klass_categories: { code: 'WS' })
             .group('applicants.navigator_id', 'trainees.funding_source_id')
             .count

    build_nav_fs_matrix(counts)
  end

  def build_occ_counts_matrix
    counts = KlassTrainee
             .joins(trainee: :applicant, klass: :klass_category)
             .where.not(klass_categories: { code: 'WS' })
             .group('applicants.navigator_id', 'trainees.funding_source_id')
             .count
    build_nav_fs_matrix(counts)
  end

  def navigator_ids
    navigators.keys
  end

  # counts is a group by query result with [nav_id, fs_id] as key
  def build_nav_fs_matrix(counts, link_method = nil)
    am = ArrayMatrix.new(counts, navigator_ids, fs_ids)

    c_sum = am.columns_sum
    am.prepend_column(c_sum, '')
    r_sum = am.rows_sum
    am.prepend_row(r_sum)
    am.create_links!(link_method) if link_method
    am
  end

  def placed_counts_group_by_nav_fs
    trainees_group_by(status: 4)
  end

  def ojt_enrolled_counts_group_by_nav_fs
    trainees_group_by(status: 5)
  end

  def incumbent_counts_group_by_nav_fs
    trainees_group_by("applicants.current_employment_status = 'Incumbent Worker'")
  end

  def trainees_group_by_nav_and_fs
    trainees_group_by
  end

  def assessed_group_by_nav_and_fs
    t_assessed_ids = Trainee.joins(:trainee_assessments).pluck(:id)
    trainees_group_by(id: t_assessed_ids)
  end

  def edp_group_by_nav_and_fs
    t_edp_ids = Trainee.where.not(edp_date: nil).pluck(:id)
    trainees_group_by(id: t_edp_ids)
  end

  def trainees_group_by(predicate = nil)
    trainees = Trainee.joins(:applicant)
    trainees = trainees.where(predicate) if predicate
    trainees.group('applicants.navigator_id', 'trainees.funding_source_id')
            .count
  end

  # navs in sorted by name.
  def navigators
    return @navigators if @navigators

    navs        = grant.navigators
    @navigators = Hash[navs.map { |n| [n.id, n.name] }]
  end

  def grant
    @grant ||= Grant.find(Grant.current_id)
  end

  def fs_ids
    funding_sources.keys
  end

  def fs_names
    funding_sources.values
  end

  def navigator_names
    navigators.values
  end

  # returns fundings sources as hash id => name
  # since some trainees may not have fs assigned includes nil => 'N/A'
  def funding_sources
    return @funding_sources if @funding_sources

    @funding_sources = Hash[*FundingSource.order(:name).pluck(:id, :name).flatten]
    @funding_sources[nil] = 'FS N/A' if Trainee.where(funding_source_id: nil).any?
    @funding_sources
  end

  def nav_fs_link(count, nav_id = '', fs_id = '')
    q = build_q_params(nav_id, fs_id)
    link(count, q)
  end

  def nav_fs_assessed_link(count, nav_id = '', fs_id = '')
    q = build_q_params(nav_id, fs_id, nil, true)
    link(count, q)
  end

  def placed_link(count, nav_id = '', fs_id = '')
    q = build_q_params(nav_id, fs_id, 4)
    link(count, q)
  end

  def ojt_enrolled_link(count, nav_id = '', fs_id = '')
    q = build_q_params(nav_id, fs_id, 5)
    link(count, q)
  end

  def incumbent_link(count, nav_id = '', fs_id = '')
    q = { applicant_navigator_id_eq: nav_id }
    q.merge!(funding_source_id_eq: fs_id) if fs_id
    q.merge!(funding_source_id_null: true) unless fs_id
    q.merge!(applicant_current_employment_status_eq: 'Incumbent Worker')

    link(count, q)
  end

  def build_q_params(nav_id, fs_id, status = nil, _assessed = false)
    q = { applicant_navigator_id_eq: nav_id }
    q.merge!(funding_source_id_eq: fs_id) if fs_id
    q.merge!(funding_source_id_null: true) unless fs_id

    return q unless status

    q.merge(status_eq: status)
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
