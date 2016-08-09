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
    method = params[:method]

    @show_applicant_placements =  method ==  'trainees_reported_placement'
    @show_trainee_placements   =  method ==  'trainees_placed'

    results = send(method, params)
    @applicants = results if results.first.is_a? Applicant
    @trainees   = results if results.first.is_a? Trainee
    determine_page_title(method, params[:navigator_id])
  end

  private

  def navigator_names
    navigators.values
  end

  def generate_navigator_metrics
    @metrics = OpenStruct.new
    @metrics.headers = ['', 'Total'] + navigator_names
    @metrics.rows = [
      new_applicants_links, trainees_not_in_class_links, trainees_in_class_links,
      trainees_not_placed_links, trainees_ojt_enrolled_links, trainees_placed_links,
      trainees_reported_placement_links
    ]

    @metrics
  end

  def grant
    @grant ||= Grant.find(Grant.current_id)
  end

  def navigator_ids
    navigators.keys
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

  # New Applicants: Applicants where Funding Souce in not assigned.
  # Navigator should be determined based on the county entered by applicant
  def new_applicants_links
    ['# ' + TITLES['navigator_new_applicants']] +
      [total_new_applicants] +
      navigator_ids.map do |id|
        count = new_applicants_count(id)
        new_applicants_link(id, count)
      end
  end

  def total_new_applicants
    Trainee.where(funding_source_id: nil).count
  end

  def new_applicants_count(nav_id)
    @new_counts ||= Trainee.where(funding_source_id: nil)
                    .joins(:applicant).group(:navigator_id).count
    @new_counts[nav_id].to_i
  end

  # Trainee Not Assigned to workshop means not assigned to any class
  # Navigator should be determined based on the county entered by applicant
  def trainees_not_in_class_links
    ['# ' + TITLES['trainees_not_in_class']] +
    [total_trainees_not_in_class] +
      navigator_ids.map do |id|
        count = trainees_not_in_class_count(id)
        trainees_not_in_class_link(id, count)
      end
  end

  def total_trainees_not_in_class
    ids = Trainee.pluck(:id) -
            KlassTrainee.pluck(:trainee_id) -
            placed_trainee_ids

    ids.uniq.count
  end

  # exclude placed ones
  def trainees_not_in_class_count(nav_id)
    unless @not_in_class_counts
      trainee_ids = Trainee.pluck(:id) -
                    KlassTrainee.pluck(:trainee_id) -
                    placed_trainee_ids
      @not_in_class_counts = Trainee.where(id: trainee_ids)
                             .joins(:applicant).group(:navigator_id).count
    end
    @not_in_class_counts[nav_id].to_i
  end

  # Trainee Assigned to workshop means assigned to any class
  # Navigator should be determined based on the county entered by applicant
  def trainees_in_class_links
    ['# Trainees Assigned to Workshops'] +
    [total_trainees_in_class] +
      navigator_ids.map do |id|
        count = trainees_in_class_count(id)
        trainees_in_class_link(id, count)
      end
  end

  def total_trainees_in_class
    KlassTrainee.select(:trainee_id).distinct.count
  end

  def trainees_in_class_count(nav_id)
    unless @in_class_counts
      trainee_ids = KlassTrainee.pluck(:trainee_id)
      @in_class_counts = Trainee.where(id: trainee_ids)
                         .joins(:applicant).group(:navigator_id).count
    end
    @in_class_counts[nav_id].to_i
  end

  def placed_trainee_ids
    Trainee.joins(:trainee_interactions)
      .where(trainee_interactions: { status: [4, 5, 6],
                                     termination_date: nil })
      .joins(:applicant)
      .pluck(:id)
  end

  # Active Trainees -> Not Placed Trainees
  # Placement is based on TraineeInteractions entered by user
  def trainees_not_placed_links
    ['# of Active Trainees'] +
      [total_trainees_not_placed] +
      navigator_ids.map do |id|
        count = not_placed_count(id)
        trainees_not_placed_link(id, count)
      end
  end

  def total_trainees_not_placed
    Trainee.where.not(id: placed_trainee_ids).count
  end

  def not_placed_count(nav_id)
    unless @not_placed_counts
      not_placed_ids = Trainee.pluck(:id) - placed_trainee_ids
      @not_placed_counts = Trainee.where(id: not_placed_ids)
                           .joins(:applicant).group(:navigator_id).count
    end
    @not_placed_counts[nav_id].to_i
  end

  # OJT Enrolled Trainees
  # TraineeInteractions: status = ojt enrolled and termination_date is nil
  def trainees_ojt_enrolled_links
    ['# of Trainees OJT Enrolled'] +
    [total_ojt_enrolled] +
      navigator_ids.map do |id|
        count = ojt_enrolled_count(id)
        trainees_ojt_enrolled_link(id, count)
      end
  end

  def total_ojt_enrolled
    Trainee.joins(:trainee_interactions, :applicant)
           .where(trainee_interactions: { status: 5,
                                          termination_date: nil })
           .count
  end

  def ojt_enrolled_count(nav_id)
    @ojt_enrolled_counts ||= Trainee.joins(:trainee_interactions, :applicant)
                             .where(trainee_interactions: { status: 5,
                                                            termination_date: nil })
                             .group(:navigator_id).count

    @ojt_enrolled_counts[nav_id].to_i
  end

  def trainees_ojt_enrolled(params)
    navigator_id = params.is_a?(Hash) ? params[:navigator_id] : params
    Trainee.joins(:trainee_interactions, :applicant)
      .where(trainee_interactions: { status: 5,
                                     termination_date: nil })
      .where(applicants: { navigator_id: navigator_id })
      .order(:first, :last)
      .uniq
  end

  def trainees_ojt_enrolled_link(id, count)
    applicants_link('trainees_ojt_enrolled', id, count)
  end

  # Placed Trainees
  # TraineeInteractions: status = 4(No OJT) or 6( OJT Completed)
  def trainees_placed_links
    ['# of Trainees Placed'] +
    [total_placed_count] +
      navigator_ids.map do |id|
        count = placed_count(id)
        trainees_placed_link(id, count)
      end
  end

  def total_placed_count
    Trainee.joins(:trainee_interactions)
           .where(trainee_interactions: { status: [4, 6],
                                          termination_date: nil })
           .joins(:applicant)
           .count
end

  def placed_count(nav_id)
    unless @placed_counts
      placed_ids = Trainee.joins(:trainee_interactions)
                   .where(trainee_interactions: { status: [4, 6],
                                                  termination_date: nil })
                   .joins(:applicant)
                   .pluck(:id)

      @placed_counts = Trainee.where(id: placed_ids)
                       .joins(:applicant).group(:navigator_id).count
    end
    @placed_counts[nav_id].to_i
  end

  # All the trainees who submitted placement information
  # Navigator is determined by navigator_id.
  def trainees_reported_placement_links
    ['# of Applicants Reported Placement'] +
    [total_reported_placement] +
      navigator_ids.map do |id|
        count = reported_placement_count(id)
        trainees_reported_placement_link(id, count)
      end
  end

  def total_reported_placement
    Trainee.joins(:trainee_placements, :applicant).count
  end

  def reported_placement_count(nav_id)
    @reported_counts ||= Trainee.joins(:trainee_placements, :applicant)
                         .group(:navigator_id).count
    @reported_counts[nav_id].to_i
  end

  def navigator_new_applicants(params)
    navigator_id = params.is_a?(Hash) ? params[:navigator_id] : params
    new_applicants.where(navigator_id: navigator_id)
  end

  def navigator_label(nav)
    return 'Not Assigned' unless nav
    User.find(nav).name
  end

  def trainees_in_class(params)
    navigator_id = params.is_a?(Hash) ? params[:navigator_id] : params
    Trainee.where(id: trainee_ids_in_klass(navigator_id)).order(:first, :last)
  end

  def trainee_ids_in_klass(navigator_id)
    Trainee.joins(:klass_trainees, :applicant)
      .where(applicants: { navigator_id: navigator_id }).pluck(:id)
  end

  def navigator_trainees(navigator_id)
    Trainee.joins(:applicant)
      .where(applicants: { navigator_id: navigator_id }).order(:first, :last)
  end

  def trainees_placed(params)
    navigator_id = params.is_a?(Hash) ? params[:navigator_id] : params
    Trainee.joins(:trainee_interactions, :applicant)
      .where(trainee_interactions: { status: [4, 6],
                                     termination_date: nil })
      .where(applicants: { navigator_id: navigator_id })
      .order(:first, :last)
      .uniq
  end

  def trainees_not_placed(params)
    navigator_id = params.is_a?(Hash) ? params[:navigator_id] : params
    navigator_trainees(navigator_id) - trainees_placed(navigator_id)
  end

  def trainees_reported_placement(params)
    navigator_id = params.is_a?(Hash) ? params[:navigator_id] : params
    Trainee.joins(:trainee_placements, :applicant)
      .where(applicants: { navigator_id: navigator_id }).order(:first, :last).uniq
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
