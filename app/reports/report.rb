# mother of all reports
class Report
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :report_name, :start_date, :end_date, :include_all_dates,
                :klass_id, :klass_ids, :include_all_dates, :user_id

  TRAINEES_DETAILS                = 'trainees_details'
  TRAINEES_DETAILS_WITH_PLACEMENT = 'trainees_details_with_placement'
  TRAINEES_PLACED                 = 'trainees_placed'
  TRAINEES_NOT_PLACED             = 'trainees_not_placed'
  TRAINEES_STATUS                 = 'trainees_status'
  TRAINEES_ACTIVITY               = 'trainees_activity'
  TRAINEES_NEAR_BY_EMPLOYERS      = 'trainees_near_by_employers'
  JOBS_APPLIED                    = 'jobs_applied'
  ACTIVE_EMPLOYERS                = 'active_employers'
  EMPLOYERS_HIRED                 = 'employers_hired'
  EMPLOYERS_INTERESTED_TRAINEES   = 'employers_interested_in_trainees'
  EMPLOYERS_ACTIVITIES_WITH_NOTES = 'employers_activities_with_notes'
  EMPLOYERS_ADDRESS_MISSING       = 'employers_no_address'
  CLASS_TRAINEES                  = 'class_trainees'

  REPORT_CLASS = {
    TRAINEES_PLACED                   => :TraineesPlacedReport,
    TRAINEES_DETAILS                  => :TraineesDetailsReport,
    TRAINEES_DETAILS_WITH_PLACEMENT   => :TraineesDetailsWithPlacementReport,
    TRAINEES_STATUS                   => :TraineesStatusReport,
    TRAINEES_ACTIVITY                 => :TraineesActivityReport,
    TRAINEES_NOT_PLACED               => :TraineesNotPlacedReport,
    TRAINEES_NEAR_BY_EMPLOYERS        => :TraineesNearByEmployersReport,
    JOBS_APPLIED                      => :JobsAppliedReport,
    EMPLOYERS_HIRED                   => :EmployersHiredReport,
    ACTIVE_EMPLOYERS                  => :ActiveEmployersReport,
    EMPLOYERS_ACTIVITIES_WITH_NOTES   => :EmployersActivitiesWithNotesReport,
    EMPLOYERS_INTERESTED_TRAINEES     => :EmployersInterestedReport,
    EMPLOYERS_ADDRESS_MISSING         => :EmployersNoAddressReport,
    CLASS_TRAINEES                    => :ClassTraineesReport
    }

  def initialize(user, params = nil)
    @report_name = params && params[:report_name]
    init_klass_ids(user, params) if params
    init_dates(params) if params && params[:start_date]
    @user_id = user.id
    post_initialize(params)
  end

  def persisted?
    false
  end

  def self.reports_by_type
    [['Class Reports', class_reports],
     ['Trainee Reports', trainee_reports],
     ['Employer Reports', employer_reports]]
  end

  def self.class_reports
    [CLASS_TRAINEES]
  end

  def self.trainee_reports
    [TRAINEES_DETAILS, TRAINEES_DETAILS_WITH_PLACEMENT, TRAINEES_PLACED,
     TRAINEES_NOT_PLACED, TRAINEES_STATUS, TRAINEES_ACTIVITY, JOBS_APPLIED,
     TRAINEES_NEAR_BY_EMPLOYERS]
  end

  def self.employer_reports
    [EMPLOYERS_HIRED, EMPLOYERS_INTERESTED_TRAINEES, ACTIVE_EMPLOYERS,
     EMPLOYERS_ACTIVITIES_WITH_NOTES, EMPLOYERS_ADDRESS_MISSING]
  end

  def start_date
    @start_date || 1.week.ago.to_date.to_s
  end

  def end_date
    @end_date || Time.now.to_date.to_s
  end

  def klasses
    return [] unless klass_ids
    # fail 'Class(s) not selected for report' unless klass_ids
    Klass.includes(college: :address).where(klasses: { id: klass_ids })
  end

  def self.new_report(user, params)
    report_class(params[:report_name]).new(user, params)
  end

  def self.create(user, params)
    report_class(params[:report_name]).new(user, params)
  end

  def template
    report_name.underscore.gsub('_report', '')
  end

  def render_counts
    strong_class = "<strong class='align-right' style='font-color: blue'>"
    ctxt = "#{count_label}: #{count}"
    (strong_class + ctxt + '</strong>').html_safe
  end

  def count
    fail 'Subclass should implement count method'
  end

  def count_label
    'Found'
  end

  def download_button
    return nil unless count > 0

    btnclass = 'btn btn-flat btn-small btn-primary pull-right'

    "<button type='button' id = 'btnExport' class='#{btnclass}' name='export'>
      <i class='icon-cloud-download icon-2x'></i>
    </button><br><br>".html_safe
  end

  private

  def self.report_class(r_name)
    REPORT_CLASS[r_name].to_s.constantize
  end

  def init_dates(params)
    @start_date = opero_str_to_date(params[:start_date])
    @end_date = opero_str_to_date(params[:end_date])
    @include_all_dates = params[:include_all_dates].to_i == 1 ||
                         @start_date.blank? || @end_date.blank?
  end

  def init_klass_ids(user, params)
    @klass_id = params[:klass_id]
    @klass_ids = params[:klass_ids]
    return unless @klass_id || @klass_ids
    k_ids = (@klass_id && [@klass_id]) || @klass_ids
    k_ids.delete('')
    all_klasses = k_ids.blank? || k_ids.include?('0')
    @klass_ids = all_klasses ? user.klasses.pluck(:id) : k_ids
  end
end
