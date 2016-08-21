# typically used for download
class ExcelFile
  STYLES = [:trainee_id]
  attr_reader :user, :data_name, :sheet_name, :package, :sheet, :styles
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

    generate_styles
    @sheet = package.workbook.add_worksheet(name: sheet_name || data_name)
  end

  def add_sheet(name)
    @sheet = package.workbook.add_worksheet(name: name)
  end

  def save(col_styles = [])
    col_styles.each do |col, style|
      sheet.col_style col, styles[style], :row_offset => 1 if styles[style]
    end

    package.serialize file_path
  end

  def file_name
    data_name + "_#{user.id}.xlsx"
  end

  def file_path
    Rails.root.join('tmp/').to_s + file_name
  end

  def generate_styles
    @styles = {}
    styles[:trainee_id] = package.workbook.styles.add_style :format_code => "0########"
  end
end
