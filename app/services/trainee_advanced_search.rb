# performs advanced search and build excel file
# can also email it to the user
class TraineeAdvancedSearch
  attr_accessor :account_id, :grant_id, :user_id, :q

  GRANT_TYPES = ['RTW'].freeze
  GRANT_ATTRIBUTES = { 'RTW' => ['EDP_Date', 'Class Categories'] }.freeze

  def initialize(user)
    @account_id = Account.current_id
    @grant_id = Grant.current_id
    @user_id = user.id
  end

  def search(q_params)
    Account.current_id = @account_id
    Grant.current_id = @grant_id
    user_trainees = user.trainees_for_search(q_params)
    @q = user_trainees.ransack(q_params)
    search_by_grant_type
  end

  def search_for_applicant_grant
    @q.result.includes(
      :funding_source,
      :home_address,
      :trainee_notes,
      :assessments,
      :trainee_files,
      :ui_verified_notes,
      :job_search_profile,
      klasses: [:college, :klass_category],
      trainee_interactions: [:employer],
      tact_three: [:education],
      applicant: [:navigator, :sector]
    )
  end

  def search_for_standard_grant
    @q.result.includes(
      :funding_source,
      :home_address,
      :trainee_notes,
      :assessments,
      :trainee_files,
      :ui_verified_notes,
      :trainee_services,
      klasses: [:college, :klass_category],
      trainee_interactions: [:employer],
      tact_three: [:education]
    )
  end

  def search_by_grant_type
    grant.trainee_applications? ? search_for_applicant_grant : search_for_standard_grant
  end

  def send_results(q_params)
    build_document(q_params)
    excel_file.send_to_user('Trainees - Advanced Search - Data')
    Rails.logger.info "TAS file sent by email to #{user.name}"
  end

  # rubocop:disable AbcSize
  def build_document(q_params)
    trainees = search(q_params)
    excel_file.add_row header
    trainees.find_each do |t|
      if grant.trainee_applications? && t.applicant.nil?
        notify_applicant_missing(t)
        next
      end
      excel_file.add_row view_builder.row(t)
    end
    excel_file.save
  end

  def header
    view_builder.header
  end

  def view_builder
    @builder ||= TraineeAdvancedSearchViewBuilder.new(grant, self)
  end

  def file_name
    excel_file.file_name
  end

  def file_path
    excel_file.file_path
  end

  def grant
    @grant ||= Grant.find grant_id
  end

  def excel_file
    @ef ||= ExcelFile.new(user, 'trainee_data')
  end

  def user
    Account.current_id = @account_id
    Grant.current_id = @grant_id
    User.find user_id
  end

  def grant_attributes?
    GRANT_TYPES.include?(grant.type)
  end

  def grant_specific_headers
    grant_attributes? ? GRANT_ATTRIBUTES[grant.type] : []
  end

  def grant_specific_values(trainee)
    return [] unless grant_attributes?

    GRANT_ATTRIBUTES[grant.type].map do |attribute|
      trainee.send(attribute.downcase.tr(' ', '_'))
    end
  end

  def notify_applicant_missing(t)
    AdminMailer.notify_applicant_missing(t).deliver_now
  end
end
