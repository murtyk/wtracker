# metrics for grant where applicants can apply
# definitions:
# new applicant: Applicant of Trainee whose funding source not assigned
class ApplicantMetrics
  # need this for link_to
  include ActionView::Helpers::UrlHelper
  attr_reader :metrics, :trainees, :applicants, :title,
              :show_applicant_placements, :show_trainee_placements,
              :trainee_status_metrics

  def initialize(user = nil)
    @user    = user
    @metrics = OpenStruct.new
  end

  # dashboard menu
  def generate_dashboard
    # @metrics.by_navigator_and_status   = by_navigator_and_status
    # @metrics.all_trainees_by_navigator = all_trainees_by_navigator
    # @metrics.applicants_by_status      = applicants_by_status
    # @metrics.applicants_by_navigator   = applicants_by_navigator
    # @metrics.trainees_by_navigator     = trainees_by_navigator
    @metrics
  end

  # for applicant analysis menu
  def generate_analysis
    tsm = TraineeStatusMetrics.new(@user)
    @trainee_status_metrics = tsm.generate(false)
    generate_navigator_metrics
  end

  def query(params)
    return nil unless params[:method]
    @show_applicant_placements =  params[:method] ==  'trainees_reported_placement'
    @show_trainee_placements   =  params[:method] ==  'trainees_placed'
    results = send(params[:method], params)
    @applicants = results if results.first.is_a? Applicant
    @trainees   = results if results.first.is_a? Trainee
    determine_page_title(params[:method], params[:navigator_id])
  end

  private

  def by_navigator_and_status
    total_a = 0
    total_d = 0
    metrices = @navigators.map do |navigator|
      metric = OpenStruct.new
      applicants = Applicant.where(navigator_id: navigator[0])
      metric.name = navigator[1]
      metric.accepted_count = applicants.where(status: 'Accepted').count
      metric.declined_count = applicants.where(status: 'Declined').count
      total_a              += metric.accepted_count
      total_d              += metric.declined_count
      metric
    end
    metric = OpenStruct.new
    metric.name = 'Total'
    metric.accepted_count = total_a
    metric.declined_count = total_d
    metrices << metric
    metrices
  end

  # one column per funding source, count of trainees need support services
  def all_trainees_by_navigator
    funding_sources = FundingSource.order(:name).pluck(:id, :name)

    header = OpenStruct.new
    header.funding_sources = funding_sources.map { |fs| fs[1] }

    total  = OpenStruct.new
    total.name = 'Total'
    total.trainee_count = 0
    total.fs_counts = Array.new(funding_sources.count, 0)

    metrices = @navigators.map do |nav|
      metric      = OpenStruct.new
      nav[0]      = nil if nav[0] == 0
      trainees    = Trainee.joins(:applicant).where(applicants: { navigator_id: nav[0] })

      metric.name          = nav[1]
      metric.trainee_count = trainees.count
      total.trainee_count += metric.trainee_count

      fs_counts = []
      i = 0
      funding_sources.each do |fs|
        fs_count = trainees.where(funding_source_id: fs[0]).count
        fs_counts << fs_count
        total.fs_counts[i] += fs_count
        i += 1
      end
      metric.fs_counts = fs_counts
      applicant_ids = Applicant.where(trainee_id: trainees.pluck(:id)).pluck(:id)
      ss_count = ApplicantSpecialService.where(applicant_id: applicant_ids)
                                        .group(:applicant_id).count.count
      metric.ss_count = ss_count
      metric
    end
    [header, metrices + [total]]
  end

  def funding_sources
    return @funding_sources if @funding_sources
    fs = FundingSource.pluck(:id, :name)
    @funding_sources = Hash[fs.map { |id, name| [id, name] }]
    @funding_sources[nil] = 'Not Assigned' if new_applicants.any?
    @funding_sources
  end

  def navigator_names
    @navigators.map { |id, name| name }
  end

  def generate_navigator_metrics
    # New Applicants: Applicants where Funding Souce in not assigned.
    # Navigator should be determined based on the county entered by applicant
    new_applicants_counts        = ['# of New Applicants']

    # Trainee Not Assigned to workshop means not assigned to any class
    # Navigator should be determined based on the county entered by applicant
    # Funding Source does not matter - all trainees
    trainees_not_in_class_counts = ['# Trainees not Assigned to Workshops']

    # Trainee Assigned to workshop means assigned to any class
    # Navigator should be determined based on the county entered by applicant
    # Funding Source does not matter - all trainees
    trainees_in_class_counts     = ['# Trainees Assigned to Workshops']

    # Active Trainees -> Not Placed Trainees
    # Placement is based on TraineeInteractions entered by user
    # Navigator is determined by navigator_id.
    trainees_not_placed_counts   = ['# of Active Trainees']

    # Not Placed Trainees
    # Placement is based on TraineeInteractions entered by user
    # Navigator is determined by navigator_id.
    trainees_placed_counts        = ['# of Trainees Placed']

    # All the trainees who submitted placement information
    # Navigator is determined by navigator_id.
    trainees_reported_placements_counts = ['# of Applicants Reported Placement']

    navigators.each do |id, name|
      links = navigator_dashboard_counts_links(id)
      new_applicants_counts               << links[0]
      trainees_not_in_class_counts        << links[1]
      trainees_in_class_counts            << links[2]
      trainees_not_placed_counts          << links[3]
      trainees_placed_counts              << links[4]
      trainees_reported_placements_counts << links[5]
    end

    @metrics = OpenStruct.new
    @metrics.headers = [''] + navigator_names
    @metrics.rows = [
      new_applicants_counts, trainees_not_in_class_counts, trainees_in_class_counts,
      trainees_not_placed_counts, trainees_placed_counts,
      trainees_reported_placements_counts
    ]

    @metrics
  end

  def navigator_dashboard_counts_links(id)
    count = navigator_new_applicants(id).count
    links = [new_applicants_link(id, count)]

    count = trainee_ids_not_in_klass(id).count
    links << trainees_not_in_class_link(id, count)

    count = trainee_ids_in_klass(id).count
    links << trainees_in_class_link(id, count)

    count = trainees_not_placed(id).count
    links << trainees_not_placed_link(id, count)

    count = trainees_placed(id).count
    links << trainees_placed_link(id, count)

    count = trainees_reported_placement(id).count
    links << trainees_reported_placement_link(id, count)
  end

  def grant
    @grant ||= Grant.find(Grant.current_id)
  end

  def navigators
    return @navigators if @navigators
    navs        = grant.navigators
    navs        = ([@user] + navs).uniq if @user.navigator?
    @navigators = Hash[navs.map { |n| [n.id, n.name] }]
  end

  def new_applicants
    @new_applicants ||= Applicant.joins(:trainee)
                                 .where(trainees: { funding_source_id: nil })
                                 .order(:first_name, :last_name)
  end

  def navigator_new_applicants(params)
    navigator_id = params.is_a?(Hash) ? params[:navigator_id] : params
    new_applicants.where(county_id: navigator_county_ids(navigator_id))
  end

  def applicants_by_status
    Applicant.group(:status).count
  end

  def trainees_by_navigator
    weekly_by_navigator('Accepted')
  end

  def applicants_by_navigator
    weekly_by_navigator
  end

  def weekly_by_navigator(status = nil)
    weeks = {}
    applicants = status ? Applicant.where(status: status) : Applicant
    h_date_navs = applicants.group(:created_at, :navigator_id).order(:created_at).count
    h_date_navs.each do |date_nav, count|
      date, nav         = date_nav
      week              = week_label(date)
      navigator         = navigator_label(nav)

      weeks[week]           ||= Hash.new(0)
      weeks[week][navigator] += count
    end
    weeks
  end

  def week_label(date)
    date.monday.strftime('%m/%d/%Y') + ' - ' + date.sunday.strftime('%m/%d/%Y')
  end

  def navigator_label(nav)
    return 'Not Assigned' unless nav
    User.find(nav).name
  end

  # return applicants where
  # -trainees not assigned to a class
  # -applicant county belongs to the navigator in context
  def trainees_not_in_class(params)
    navigator_id = params.is_a?(Hash) ? params[:navigator_id] : params
    Trainee.where(id: trainee_ids_not_in_klass(navigator_id)).order(:first, :last)
  end

  def trainee_ids_not_in_klass(navigator_id)
    trainee_ids = trainees_from_navigator_counites(navigator_id).pluck(:id)
    trainee_ids - KlassTrainee.where(trainee_id: trainee_ids).pluck(:trainee_id)
  end

  def trainees_in_class(params)
    navigator_id = params.is_a?(Hash) ? params[:navigator_id] : params
    Trainee.where(id: trainee_ids_in_klass(navigator_id)).order(:first, :last)
  end

  def trainee_ids_in_klass(navigator_id)
    trainee_ids = trainees_from_navigator_counites(navigator_id).pluck(:id)
    KlassTrainee.where(trainee_id: trainee_ids).pluck(:trainee_id).uniq
  end

  def trainees_from_navigator_counites(navigator_id)
    Trainee.joins(:applicant)
           .where(applicants: { county_id: navigator_county_ids(navigator_id) })
  end

  def navigator_trainees(navigator_id)
    Trainee.joins(:applicant)
           .where(applicants: { navigator_id: navigator_id }).order(:first, :last)
  end

  def navigator_trainee_ids(navigator_id)
    navigator_trainees(navigator_id).pluck(:id)
  end

  def navigator_county_ids(navigator_id)
    navigator_counties(navigator_id).pluck(:county_id)
  end

  def navigator_counties(navigator_id)
    UserCounty.where(user_id: navigator_id)
  end

  def trainees_placed(params)
    navigator_id = params.is_a?(Hash) ? params[:navigator_id] : params
    trainee_ids = navigator_trainee_ids(navigator_id)
    Trainee.joins(:trainee_interactions)
           .where(trainee_interactions: { trainee_id: trainee_ids })
           .order(:first, :last)
           .uniq
  end

  def trainees_not_placed(params)
    navigator_id = params.is_a?(Hash) ? params[:navigator_id] : params
    navigator_trainees(navigator_id) - trainees_placed(navigator_id)
  end

  def trainees_reported_placement(params)
    navigator_id = params.is_a?(Hash) ? params[:navigator_id] : params
    trainee_ids = navigator_trainee_ids(navigator_id)
    Trainee.joins(:trainee_placements)
           .where(trainee_placements: { trainee_id: trainee_ids })
           .order(:first, :last)
           .uniq
  end

  def new_applicants_link(id, count)
    applicants_link('navigator_new_applicants', id, count)
  end

  def trainees_not_in_class_link(id, count)
    href = url_helpers.near_by_colleges_trainees_path

    link_to(count, href)
  end

  def trainees_in_class_link(id, count)
    applicants_link('trainees_in_class', id, count)
  end

  def trainees_not_placed_link(id, count)
    applicants_link('trainees_not_placed', id, count)
  end

  def trainees_placed_link(id, count)
    applicants_link('trainees_placed', id, count)
  end

  def trainees_reported_placement_link(id, count)
    applicants_link('trainees_reported_placement', id, count)
  end

  def applicants_link(method, id, count)
    href = url_helpers.applicants_path(query: { method: method, navigator_id: id })
    link_to(count, href)
  end

  # need this for href
  def url_helpers
    Rails.application.routes.url_helpers
  end

  TITLES = {
    'navigator_new_applicants'    => 'New Applicants',
    'trainees_not_in_class'       => 'Trainees not Assigned to Workshops',
    'trainees_in_class'           => 'Trainees Assigned to Workshops',
    'trainees_not_placed'         => 'Active Trainees',
    'trainees_placed'             =>  'Trainees Placed',
    'trainees_reported_placement' => 'Applicants Reported Placements'
  }
  def determine_page_title(method, navigator_id)
    navigator = User.find navigator_id
    @title = navigator.name + '  -  ' + TITLES[method]
  end
end
