include UtilitiesHelper
# mother of all reports
class Report
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :report_name, :start_date, :end_date, :include_all_dates,
                :klass_id, :klass_ids, :user_id, :user

  TRAINEES_DETAILS                = 'trainees_details'
  TRAINEES_DETAILS_WITH_PLACEMENT = 'trainees_details_with_placement'
  TRAINEES_PLACED                 = 'trainees_placed'
  TRAINEES_NOT_PLACED             = 'trainees_not_placed'
  TRAINEES_STATUS                 = 'trainees_status'
  TRAINEES_ACTIVITY               = 'trainees_activity'
  TRAINEES_NEAR_BY_EMPLOYERS      = 'trainees_near_by_employers'
  TRAINEES_VERIFICATION           = 'trainees_verification'
  TRAINEES_BOUNCED_EMAILS         = 'trainees_bounced_emails'
  JOBS_APPLIED                    = 'jobs_applied'
  HUB_H1B                         = 'hub_h1b'
  ACTIVE_EMPLOYERS                = 'active_employers'
  EMPLOYERS_HIRED                 = 'employers_hired'
  EMPLOYERS_ACTIVITIES_WITH_NOTES = 'employers_activities_with_notes'
  EMPLOYERS_ADDRESS_MISSING       = 'employers_no_address'
  EMPLOYERS_WITH_APPRENTICES      = 'employers_with_apprentices'
  CLASS_TRAINEES                  = 'class_trainees'
  FUNDING_SOURCE_MONTHLY          = 'funding_source_monthly'

  REPORT_CLASS = {
    TRAINEES_PLACED                   => :TraineesPlacedReport,
    TRAINEES_DETAILS                  => :TraineesDetailsReport,
    TRAINEES_DETAILS_WITH_PLACEMENT   => :TraineesDetailsWithPlacementReport,
    TRAINEES_STATUS                   => :TraineesStatusReport,
    TRAINEES_ACTIVITY                 => :TraineesActivityReport,
    TRAINEES_VERIFICATION             => :TraineesVerificationReport,
    TRAINEES_NOT_PLACED               => :TraineesNotPlacedReport,
    TRAINEES_NEAR_BY_EMPLOYERS        => :TraineesNearByEmployersReport,
    TRAINEES_BOUNCED_EMAILS           => :TraineesBouncedEmailsReport,
    JOBS_APPLIED                      => :JobsAppliedReport,
    HUB_H1B                           => :HubH1bReport,
    EMPLOYERS_HIRED                   => :EmployersHiredReport,
    ACTIVE_EMPLOYERS                  => :ActiveEmployersReport,
    EMPLOYERS_ACTIVITIES_WITH_NOTES   => :EmployersActivitiesWithNotesReport,
    EMPLOYERS_ADDRESS_MISSING         => :EmployersNoAddressReport,
    EMPLOYERS_WITH_APPRENTICES        => :EmployersWithApprenticesReport,
    CLASS_TRAINEES                    => :ClassTraineesReport,
    FUNDING_SOURCE_MONTHLY            => :FundingSourceMonthlyReport
  }

  def initialize(user, params = nil)
    @user_id = user.id
    @user = user

    @report_name = params && params[:report_name]
    init_klass_ids(user, params) if params
    init_dates(params) if params
    post_initialize(params)
  end

  def persisted?
    false
  end

  def self.reports_by_type(user)
    [
     ['Class Reports', class_reports],
     ['Trainee Reports', trainee_reports(user)],
     ['Employer Reports', employer_reports(user)],
     ['Funding Source Reports', funding_source_reports(user)]
   ]
  end

  def self.class_reports
    [CLASS_TRAINEES]
  end

  def self.trainee_reports(user)
    list =
    [TRAINEES_DETAILS, TRAINEES_DETAILS_WITH_PLACEMENT, TRAINEES_PLACED,
     TRAINEES_NOT_PLACED, TRAINEES_STATUS, TRAINEES_ACTIVITY,
     TRAINEES_VERIFICATION, JOBS_APPLIED
    ]

    return list unless user.admin_access?

    list + [TRAINEES_NEAR_BY_EMPLOYERS, HUB_H1B, TRAINEES_BOUNCED_EMAILS]
  end

  def self.employer_reports(user)
    return [EMPLOYERS_HIRED,
            EMPLOYERS_ADDRESS_MISSING,
            EMPLOYERS_ACTIVITIES_WITH_NOTES] unless user.admin_access?

    list = [EMPLOYERS_HIRED, ACTIVE_EMPLOYERS,
            EMPLOYERS_ACTIVITIES_WITH_NOTES, EMPLOYERS_ADDRESS_MISSING]

    if Grant.current_grant && Grant.current_grant.type == 'GAINS'
      list << EMPLOYERS_WITH_APPRENTICES
    end

    list
  end

  def self.funding_source_reports(user)
    return [FUNDING_SOURCE_MONTHLY]
  end

  def start_date
    @start_date || 1.week.ago.to_date.to_s
  end

  def end_date
    @end_date || Time.now.to_date.to_s
  end

  def klasses
    return [] unless klass_ids
    Klass.includes(college: :address).where(id: klass_ids)
  end

  def self.new_report(user, params)
    report_class(params[:report_name]).new(user, params)
  end

  def self.create(user, params)
    report_class(params[:report_name]).new(user, params)
  end

  def template
    'report'
  end

  def selection_partial
    'class_selection'
  end

  def table_partial
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
    @start_date = opero_str_to_date(params[:start_date]) if params[:start_date]
    @end_date = opero_str_to_date(params[:end_date]) if params[:end_date]
    @include_all_dates = params[:include_all_dates].to_i == 1 ||
                         (@start_date.blank? && @end_date.blank?)
  end

  def init_klass_ids(user, params)
    k_ids = k_ids_from_params(params)

    return unless k_ids

    all_klasses = k_ids.blank? || k_ids.include?('0')
    @klass_ids = all_klasses ? user.klasses.pluck(:id) : k_ids
  end

  def k_ids_from_params(params)
    @klass_id = params[:klass_id]
    @klass_ids = params[:klass_ids]
    return unless @klass_id || @klass_ids
    k_ids = (@klass_id && [@klass_id]) || @klass_ids
    k_ids.delete('')
    k_ids
  end

  def klass_link(k)
    href = "/klasses/#{k.id}"
    name_link(href, k.to_label)
  end

  def trainee_link(t)
    href = "/trainees/#{t.id}"
    name_link(href, t.name)
  end

  def employer_link(e)
    href = "/employers/#{e.id}"
    name_link(href, e.name)
  end

  def name_link(href, name)
    "<a href = '#{href}'>#{name}</a>".html_safe
  end

  def notes(trainee)
    trainee
      .trainee_notes
      .map { |tn| "#{tn.created_at.to_date}: #{tn.notes}" }.join('<br>')
      .html_safe
  end
end
