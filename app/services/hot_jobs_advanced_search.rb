# performs advanced search and build excel file
# can also email it to the user
class HotJobsAdvancedSearch
  attr_accessor :account_id, :grant_id, :user_id, :q

  def initialize(user)
    @account_id = Account.current_id
    @grant_id = Grant.current_id
    @user_id = user.id
  end

  def search(q_params)
    Account.current_id = @account_id
    Grant.current_id = @grant_id
    @q = HotJob.ransack(q_params)
    @q.result.includes(:employer, :user)
  end

  def send_results(q_params)
    build_document(q_params)
    excel_file.send_to_user('Hot Jobs')
  end

  def build_document(q_params)
    hot_jobs = search(q_params)
    excel_file.add_row header
    hot_jobs.each { |hj| excel_file.add_row build_row(hj) }
    excel_file.save
  end

  def header
    ['Date Posted', 'Posted By', 'Location', 'Title', 'Description', 'Salary']
  end

  def row_keys
    @row_keys ||= header.map { |h| h.downcase.gsub(' ', '_') }
  end

  def build_row(hj)
    [hj.date_posted, hj.user.email, hj.location, hj.title, hj.description, hj.salary]
  end

  def file_name
    excel_file.file_name
  end

  def file_path
    excel_file.file_path
  end

  def excel_file
    @ef ||= ExcelFile.new(user, 'hot_jobs')
  end

  def user
    Account.current_id = @account_id
    Grant.current_id = @grant_id
    User.find user_id
  end
end
