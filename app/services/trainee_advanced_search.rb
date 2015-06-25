require 'axlsx'
# performs advanced search and build excel file
# can also email it to the user
class TraineeAdvancedSearch
  attr_accessor :account_id, :grant_id, :user_id, :q

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

  def search_by_grant_type
    if grant.trainee_applications?
      return @q.result.includes(:klasses, :job_search_profile, :assessments,
                                :funding_source, :home_address,
                                tact_three: [:education],
                                applicant: [:navigator, :sector])
    end
    @q.result.includes(:klasses, :funding_source, :home_address,
                       :assessments, tact_three: [:education])
  end

  def send_results(q_params)
    build_document(q_params)
    doc = { file_name => File.read(file_path) }
    subject = 'Trainees - Advanced Search - Data'
    UserMailer.send_data(user, subject, '', doc).deliver_now
  end

  def build_document(q_params)
    delete_existing_file
    trainees = search(q_params)
    sheet.add_row header
    trainees.each { |t| sheet.add_row view_builder.row(t) }
    package.serialize file_path
  end

  def header
    view_builder.header
  end

  def view_builder
    @builder ||= TraineeAdvancedSearchViewBuilder.new(grant)
  end

  def delete_existing_file
    File.delete(file_path) if File.exist?(file_path)
  end

  def file_name
    "trainee_data_#{user.id}.xlsx"
  end

  def file_path
    Rails.root.join('tmp/').to_s + file_name
  end

  def grant
    @grant ||= Grant.find grant_id
  end

  def sheet
    @sheet ||= package.workbook.add_worksheet(name: 'Trainees')
  end

  def package
    @package ||= Axlsx::Package.new
  end

  def user
    Account.current_id = @account_id
    Grant.current_id = @grant_id
    User.find user_id
  end
end
