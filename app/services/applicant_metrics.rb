# metrics for grant where applicants can apply
# definitions:
# new applicant: Applicant of Trainee whose funding source not assigned
class ApplicantMetrics
  # need this for link_to
  include ActionView::Helpers::UrlHelper
  attr_reader :metrics, :trainees, :applicants, :title,
              :show_applicant_placements, :show_trainee_placements

  def initialize(user = nil)
    @user    = user
    @metrics = OpenStruct.new
  end

  # for applicant analysis menu
  def generate_analysis
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

  def navigator_names
    @navigators.values
  end

  def generate_navigator_metrics
    # New Applicants: Applicants where Funding Souce in not assigned.
    # Navigator should be determined based on the county entered by applicant
    new_applicants_counts        = ['# of New Applicants']

    # Trainee Not Assigned to workshop means not assigned to any class
    # Navigator should be determined based on the county entered by applicant
    trainees_not_in_class_counts = ['# Trainees not Assigned to Workshops']

    # Trainee Assigned to workshop means assigned to any class
    # Navigator should be determined based on the county entered by applicant
    trainees_in_class_counts     = ['# Trainees Assigned to Workshops']

    # Active Trainees -> Not Placed Trainees
    # Placement is based on TraineeInteractions entered by user
    trainees_not_placed_counts   = ['# of Active Trainees']

    # OJT Enrolled Trainees
    # TraineeInteractions: status = ojt enrolled and termination_date is nil
    trainees_ojt_enrolled_counts = ['# of Trainees OJT Enrolled']

    # Placed Trainees
    # TraineeInteractions: status = 4(No OJT) or 6( OJT Completed)
    trainees_placed_counts        = ['# of Trainees Placed']

    # All the trainees who submitted placement information
    # Navigator is determined by navigator_id.
    trainees_reported_placements_counts = ['# of Applicants Reported Placement']

    navigators.each do |id, _name|
      links = navigator_dashboard_counts_links(id)
      new_applicants_counts               << links[0]
      trainees_not_in_class_counts        << links[1]
      trainees_in_class_counts            << links[2]
      trainees_not_placed_counts          << links[3]
      trainees_ojt_enrolled_counts        << links[4]
      trainees_placed_counts              << links[5]
      trainees_reported_placements_counts << links[6]
    end

    @metrics = OpenStruct.new
    @metrics.headers = [''] + navigator_names
    @metrics.rows = [
      new_applicants_counts, trainees_not_in_class_counts, trainees_in_class_counts,
      trainees_not_placed_counts, trainees_ojt_enrolled_counts, trainees_placed_counts,
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

    count = trainees_ojt_enrolled(id).count
    links << trainees_ojt_enrolled_link(id, count)

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

  def trainees_ojt_enrolled(params)
    navigator_id = params.is_a?(Hash) ? params[:navigator_id] : params
    trainee_ids = navigator_trainee_ids(navigator_id)
    Trainee.joins(:trainee_interactions)
      .where(trainee_interactions: { trainee_id: trainee_ids,
                                     status: 5,
                                     termination_date: nil })
      .order(:first, :last)
      .uniq
  end

  def trainees_placed(params)
    navigator_id = params.is_a?(Hash) ? params[:navigator_id] : params
    trainee_ids = navigator_trainee_ids(navigator_id)
    Trainee.joins(:trainee_interactions)
      .where(trainee_interactions: { trainee_id: trainee_ids,
                                     status: [4, 6],
                                     termination_date: nil })
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

  def trainees_not_in_class_link(_id, count)
    href = url_helpers.near_by_colleges_trainees_path

    link_to(count, href)
  end

  def trainees_in_class_link(id, count)
    applicants_link('trainees_in_class', id, count)
  end

  def trainees_not_placed_link(id, count)
    applicants_link('trainees_not_placed', id, count)
  end

  def trainees_ojt_enrolled_link(id, count)
    applicants_link('trainees_ojt_enrolled', id, count)
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
    'trainees_ojt_enrolled'       => 'Trainees OJT Enrolled',
    'trainees_placed'             =>  'Trainees Placed',
    'trainees_reported_placement' => 'Applicants Reported Placements'
  }
  def determine_page_title(method, navigator_id)
    navigator = User.find navigator_id
    @title = navigator.name + '  -  ' + TITLES[method]
  end
end
