# dashboard metrics for grants where applicants can apply.
# example grant: RTW (NJWF)
class DashboardMetrics
  # need this for link_to
  include ActionView::Helpers::UrlHelper
  attr_reader :metrics, :nav_placements, :fs_nav_placements

  def initialize
    @metrics = OpenStruct.new
    @metrics.header = ['ALL', '# Trainees'] + fs_names + ['Placed', 'OJT Enrolled']

    # for no of trainees, each fs, placed and ojt enrolled
    @metrics.totals = ['Totals']

    init_metrics_for_funding_sources
    @nav_placements = {}
    @fs_nav_placements = {}
  end

  # build rows for each funding source
  # rows is array of arrays. first row is totals.
  def init_metrics_for_funding_sources
    @metrics.fs_data = funding_sources.map do |id, name|
      os = OpenStruct.new
      os.id = id
      os.header = [name, '# Trainees',  'Placed',  'OJT Enrolled']
      os.totals = ['Totals'] # for trainees, placed and ojt enrolled

      # [nav name, # trainees, fs1 count..., placed, ojt enrolled]
      os.rows = []
      os
    end
  end

  # generates for dashboard data where grant accepts applicants
  def generate
    t_matrix = build_trainee_counts_matrix
    p_matrix = build_placements_counts_matrix
    oe_matrix = build_ojt_enrolled_counts_matrix

    summary_matrix = build_summary_matrix(t_matrix, p_matrix, oe_matrix)
    build_summary_totals_links(summary_matrix)
    build_summary_metrics_links(summary_matrix)

    build_fs_metrics_links(t_matrix, p_matrix, oe_matrix)

    metrics
  end

  private

  # builds all data values except totals row
  def build_summary_matrix(t_matrix, p_matrix, oe_matrix)
    # sum columns in t_matrix to get trainee totals by nav
    t_totals = Matrix.zero(t_matrix.row_size, 1).column(0)
    (0..t_matrix.column_size - 1).each { |c| t_totals += t_matrix.column(c) }

    # build a vector with sum of placements in each fs
    # sum columns
    p_column = Matrix.zero(p_matrix.row_size, 1).column(0)
    (0..p_matrix.column_size - 1).each { |c| p_column += p_matrix.column(c) }

    oe_column = Matrix.zero(oe_matrix.row_size, 1).column(0)
    (0..oe_matrix.column_size - 1).each { |c| oe_column += oe_matrix.column(c) }

    # now append p and oe columns and build a new matrix
    s_matrix = Matrix.columns(t_matrix.transpose.to_a << p_column)
    s_matrix = Matrix.columns(s_matrix.transpose.to_a << oe_column)

    # prepend trainee totals column
    summary = [t_totals.to_a] + s_matrix.transpose.to_a
    Matrix[*summary].transpose
  end

  def build_summary_totals_links(summary_matrix)
    total_row = sum_rows(summary_matrix).to_a
    # total row: all trainees count, fs1 trainees count, ..., placed count, oe count
    count = total_row[0]
    total_row[0] = link(count, {}) #no params

    c = 1
    funding_sources.each do |fs_id, _fs_name|
      count = total_row[c]
      total_row[c] = fs_link(count, fs_id)
      c += 1
    end

    count = total_row[-2]
    total_row[-2] = placed_link(count)

    count = total_row[-1]
    total_row[-1] = ojt_enrolled_link(count)

    @metrics.totals += total_row
  end

  def build_summary_metrics_links(matrix)
    # build links for navs
    nav_index = 0
    navigators.each do |nav_id, _nav_name|
      count = matrix[nav_index, 0]
      matrix[nav_index, 0] = nav_link(count, nav_id)

      # build links for fs counts
      c = 1 # first column is all trainees for the nav
      funding_sources.each do |fs_id, _fs_name|
        count = matrix[nav_index, c]
        matrix[nav_index, c] = link(count,
                                    funding_source_id_eq: fs_id,
                                    applicant_navigator_id_eq: nav_id)
        c += 1
      end

      # build links for placed and ojt enrolled
      count = matrix[nav_index, -2]
      matrix[nav_index, -2] = placed_nav_link(count, nav_id)

      count = matrix[nav_index, -1]
      matrix[nav_index, -1] = ojt_enrolled_nav_link(count, nav_id)

      nav_index += 1
    end

    # prepend trainee names
    summary = [navigator_names] + matrix.transpose.to_a

    @metrics.rows = summary.transpose.to_a
  end

  def build_fs_metrics_links(t_matrix, p_matrix, oe_matrix)
    # Each of the input matrix has fs columns.
    # Therefore all should have same column count.
    (0..t_matrix.column_size - 1).each do |c|
      build_fs_data_links(c, t_matrix.column(c),
                          p_matrix.column(c), oe_matrix.column(c))
    end
  end

  def build_fs_data_links(fs_index, t_column, p_column, oe_column)
    fs_id = @metrics.fs_data[fs_index].id

    # build totals for this fs
    totals_links = [fs_link(sum_array(t_column), fs_id),
                    placed_fs_link(sum_array(p_column), fs_id),
                    ojt_enrolled_fs_link(sum_array(oe_column), fs_id)]

    @metrics.fs_data[fs_index].totals += totals_links

    # convert columns data to links
    t_links = []
    p_links = []
    oe_links = []

    n = 0
    navigators.each do |nav_id, _nav_name|
      t_links << fs_nav_link(t_column[n], fs_id, nav_id)
      p_links << placed_fs_nav_link(p_column[n], fs_id, nav_id)
      oe_links << ojt_enrolled_fs_nav_link(oe_column[n], fs_id, nav_id)

      n += 1
    end

    @metrics.fs_data[fs_index].rows =
      Matrix[navigator_names, t_links.to_a, p_links.to_a, oe_links.to_a].transpose.to_a
  end

  # builds trainees counts matrix
  #         FS1    FS2
  #
  #  Nav1   v11     v12
  #
  #  Nav2   v21     v22
  #
  # matrix contains only values Vij not headers
  def build_trainee_counts_matrix
    trainee_counts = trainees_group_by_fs_and_nav # key format: [fs_id, nav_id]
    build_fs_nav_matrix(trainee_counts)
  end

  # builds trainee placements counts matrix
  #         FS1    FS2
  #
  #  Nav1   v11     v12
  #
  #  Nav2   v21     v22
  #
  # matrix contains only values Vij not headers
  def build_placements_counts_matrix
    placed_counts = placed_counts_group_by_fs_nav
    build_fs_nav_matrix(placed_counts)
  end

  def build_ojt_enrolled_counts_matrix
    enrolled_counts = ojt_enrolled_counts_group_by_fs_nav
    build_fs_nav_matrix(enrolled_counts)
  end

  # counts is group by query result with [fs_id, nav_id] as key
  def build_fs_nav_matrix(counts)
    nav_count = navigators.count
    fs_count = funding_sources.count
    matrix = Matrix.zero(nav_count, fs_count)
    nav_index = 0
    navigators.each do |nav_id, _nav_name|
      fs_index = 0
      funding_sources.each do |fs_id, _fs_name|
        matrix[nav_index, fs_index] = counts[[fs_id, nav_id]].to_i
        fs_index += 1
      end
      nav_index += 1
    end
    matrix
  end

  def placed_counts_group_by_fs_nav
    Trainee.joins(:applicant)
      .where(status: 4)
      .group('trainees.funding_source_id', 'applicants.navigator_id')
      .count
  end

  def ojt_enrolled_counts_group_by_fs_nav
    Trainee.joins(:applicant)
      .where(status: 5)
      .group('trainees.funding_source_id', 'applicants.navigator_id')
      .count
  end

  def trainees_group_by_fs_and_nav
    Trainee.joins(:applicant)
      .group('funding_source_id', 'applicants.navigator_id')
      .count
  end

  def fs_trainees_group_nav(fs_id)
    Trainee.joins(:applicant)
      .where(funding_source_id: fs_id)
      .group('applicants.navigator_id')
      .count
  end

  # return a vector that is sum of all rows
  def sum_rows(m)
    totals = Matrix.zero(1, m.column_size).row(0)
    (0..m.row_size - 1).each { |r| totals += m.row(r) }
    totals
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
    if Trainee.where(funding_source_id: nil).any?
      @funding_sources[nil] = 'FS N/A'
    end
    @funding_sources
  end

  def nav_link(count, nav_id)
    link(count, applicant_navigator_id_eq: nav_id)
  end

  def fs_link(count, fs_id)
    link(count, funding_source_id_eq: fs_id)
  end

  def fs_nav_link(count, fs_id, nav_id)
    link(count, funding_source_id_eq: fs_id, applicant_navigator_id_eq: nav_id)
  end

  def placed_link(count)
    link(count, status_eq: 4)
  end

  def placed_fs_link(count, fs_id)
    link(count, status_eq: 4, funding_source_id_eq: fs_id)
  end

  def placed_nav_link(count, nav_id)
    link(count, status_eq: 4, applicant_navigator_id_eq: nav_id)
  end

  def placed_fs_nav_link(count, fs_id, nav_id)
    link(count, status_eq: 4, funding_source_id_eq: fs_id,
                applicant_navigator_id_eq: nav_id)
  end

  def ojt_enrolled_link(count)
    link(count, status_eq: 5)
  end

  def ojt_enrolled_fs_link(count, fs_id)
    link(count, status_eq: 5, funding_source_id_eq: fs_id)
  end

  def ojt_enrolled_nav_link(count, nav_id)
    link(count, status_eq: 5, applicant_navigator_id_eq: nav_id)
  end

  def ojt_enrolled_fs_nav_link(count, fs_id, nav_id)
    link(count, status_eq: 5, funding_source_id_eq: fs_id,
                applicant_navigator_id_eq: nav_id)
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

  def sum_array(ary)
    ary.inject { |a, e| a + e }
  end
end
