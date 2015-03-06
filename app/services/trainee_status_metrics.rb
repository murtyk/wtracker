# for grants where applicants can apply
# generates trainee status (gts_id) metrics for dashboard and applicant analysis
class TraineeStatusMetrics
  # need this for link_to
  include ActionView::Helpers::UrlHelper
  attr_reader :metrics

  def initialize(user = nil)
    @user = user
    @metrics = OpenStruct.new
  end

  # both types of metrics can be generated with this method
  # when called for applicant analysis, current_user, false should be passed
  def generate(dashboard = true)
    return generate_for_dashboard if dashboard
    generate_for_analysis
  end

  # navs in sorted by name. current_user(nav) is brought to front.
  def navigators
    return @navigators if @navigators
    navs        = grant.navigators
    navs        = ([@user] + navs).uniq if @user && @user.navigator?
    @navigators = Hash[navs.map { |n| [n.id, n.name] }]
  end

  def status_ids
    statuses.values
  end

  # header:       status1  status2  status3   ...
  # each row:
  # row[1]         n01        n02     n03     ...
  # row[0]  ->  nav = [id, name]
  def generate_for_dashboard
    @metrics.headers = status_labels

    # build rows with first colums as label
    @metrics.rows = navigators.to_a.map { |n| [n] }

    status_labels.each do |label|
      status_id = statuses[label]

      status_counts =  Applicant.joins(:trainee)
                       .where(trainees: { gts_id: status_id })
                       .group(:navigator_id).count

      @metrics.rows.each do |row|
        nav_id = row[0][0]
        row << link(status_counts[nav_id].to_i,
                    gts_id_eq: status_id, applicant_navigator_id_eq: nav_id)
      end
    end
    @metrics
  end

  # header:    blank    nav1  nav2  nav3 ...
  # row[0]     status1   c1    c2    c3  ...
  def generate_for_analysis
    @metrics.headers = [''] + navigator_names

    # build rows with first column as label
    @metrics.rows = status_labels.map { |l| [l] }

    navigators.each do |nav|
      status_counts =  Trainee.joins(:applicant, :grant_trainee_status)
                       .where(applicants: { navigator_id: nav[0] })
                       .group('grant_trainee_statuses.name').count

      @metrics.rows.each do |row|
        row << link(status_counts[row[0]].to_i.to_s,
                    gts_id_eq: statuses[row[0]], applicant_navigator_id_eq: nav[0])
      end
    end
    @metrics
  end

  # names list of applicable trainee statuses for this grant
  def status_labels
    @status_labels ||= statuses.keys
  end

  # Hash of applicable Trainee Statuses for the current grant
  def statuses
    @statuses ||= Hash[*GrantTraineeStatus.pluck(:name, :id).flatten]
  end

  # names of navs sorted. current_user(nav) is brought to front.
  def navigator_names
    navigators && navigators.map { |_id, name| name }
  end

  def grant
    @grant ||= Grant.find(Grant.current_id)
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
