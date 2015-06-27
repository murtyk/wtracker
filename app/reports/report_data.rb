# for sending report data in excel file format
class ReportData
  attr_accessor :account_id, :grant_id, :user_id, :params

  def initialize(user_id, params)
    @account_id = Account.current_id
    @grant_id = Grant.current_id
    @user_id = user_id
    @params = params
  end

  def send_to_user
    excel_file.send_to_user
  end

  def excel_file
    @report ||= Report.new_report(user, params)
    @ef ||= @report.build_excel
  end

  def user
    Account.current_id = account_id
    Grant.current_id = grant_id
    User.find user_id
  end
end
