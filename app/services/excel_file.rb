# typically used for download
class ExcelFile
  attr_reader :user, :data_name, :sheet_name, :package, :sheet
  def initialize(user, data_name, sheet_name = nil)
    @user = user
    @data_name = data_name
    @sheet_name = sheet_name

    init
  end

  def add_row(row, height = nil)
    sheet.add_row row, height: height if height
    sheet.add_row row unless height
  end

  def send_to_user(subject = nil)
    save
    doc = { file_name => File.read(file_path) }
    subject ||= data_name.split('_').map(&:capitalize).join(' ')
    UserMailer.send_data(user, subject, '', doc).deliver_now
  end

  def init
    File.delete(file_path) if File.exist?(file_path)
    @package ||= Axlsx::Package.new
    package.use_shared_strings = true
    @sheet = package.workbook.add_worksheet(name: sheet_name || data_name)
  end

  def save
    package.serialize file_path
  end

  def file_name
    data_name + "_#{user.id}.xlsx"
  end

  def file_path
    Rails.root.join('tmp/').to_s + file_name
  end
end
