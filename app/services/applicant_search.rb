# frozen_string_literal: true

# performs search and build excel file
# can also email it to the user
class ApplicantSearch
  attr_accessor :account_id, :grant_id, :user_id, :filters, :applicants

  def initialize(user)
    @account_id = Account.current_id
    @grant_id = Grant.current_id
    @user_id = user.id
  end

  def perform(params)
    @filters = params
    return [] if filters.empty?

    search
  end

  def send_results(params)
    build_document(params)
    excel_file.send_to_user('Applicants Search - Data')
    Rails.logger.info "Applicants Search file sent by email to #{user.name}"
  end

  def build_document(params)
    perform(params)
    sheet.add_row header
    applicants.each { |a| add_row(a) }
    excel_file.save
  end

  def file_path
    excel_file.file_path
  end

  def file_name
    excel_file.file_name
  end

  private

  def search
    Account.current_id = @account_id
    Grant.current_id = @grant_id
    query_applicants
    apply_filters
  end

  def query_applicants
    @applicants = Applicant
                  .includes(:county, :sector)
                  .includes(trainee: %i[assessments klasses unemployment_proof_file])
                  .where(predicate)
                  .order(created_at: :desc)
  end

  def predicate
    pred = {}
    pred.merge!(navigator_id: navigator_id) unless navigator_id.blank?
    pred.merge!(status: status) unless status.blank?
    pred
  end

  def apply_filters
    apply_funding_source
    apply_edp
    apply_assessments
    apply_in_klass
    apply_name
    applicants
  end

  def apply_edp
    @applicants = applicants.where.not(trainees: { edp_date: nil }) if edp
  end

  def apply_funding_source
    return unless funding_source_id.positive?

    filter_on_trainee_ids Trainee
      .where(funding_source_id: funding_source_id)
      .pluck(:id)
  end

  def apply_assessments
    return unless assessments

    filter_on_trainee_ids Trainee.with_assessments.pluck(:id)
  end

  def apply_in_klass
    return unless in_klass

    filter_on_trainee_ids Trainee.in_klass.pluck(:id)
  end

  def apply_name
    return unless name.size.positive?

    qry = 'applicants.first_name ilike ? or applicants.last_name ilike ?'
    @applicants = applicants.where(qry, "#{name}%", "#{name}%")
  end

  def filter_on_trainee_ids(ids)
    @applicants = applicants.where(trainee_id: ids)
  end

  def navigator_id
    filters[:navigator_id]
  end

  def status
    filters[:status]
  end

  def funding_source_id
    filters[:funding_source_id].to_i
  end

  def edp
    filters[:edp].to_i.positive?
  end

  def assessments
    filters[:assessments].to_i.positive?
  end

  def in_klass
    filters[:in_klass].to_i.positive?
  end

  def name
    filters[:name].to_s
  end

  def header
    view_builder.header
  end

  def view_builder
    @builder ||= ApplicantSearchViewBuilder.new
  end

  def add_row(a)
    row_data, link = view_builder.row(a)
    row = sheet.add_row(row_data)
    sheet.add_hyperlink(location: link, ref: "P#{row.index + 1}") if link
  end

  def sheet
    excel_file.sheet
  end

  def excel_file
    @ef ||= ExcelFile.new(user, 'trainee_data')
  end

  def user
    Account.current_id = @account_id
    Grant.current_id = @grant_id
    User.find user_id
  end
end
