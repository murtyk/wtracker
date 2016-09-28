# trainees verification for unemployment
class TraineesVerificationReport < Report
  attr_reader :trainees, :trainees_count
  def post_initialize(params)
    build_trainees
  end

  def build_trainees
    @trainees = find_trainees
    @trainees_count = @trainees.count
    @trainees = @trainees.limit(show_max_rows).decorate
  end

  def find_trainees
    Trainee.includes(:home_address, :applicant)
  end

  def build_excel
    builder = TraineesVerificationViewBuilder.new
    excel_file = ExcelFile.new(user, 'trainees_verification')
    excel_file.add_row builder.header
    find_trainees.each do |trainee|
      row = builder.build_row(trainee.decorate)
      excel_file.add_row row
    end
    excel_file.save
    excel_file
  end

  def count
    trainees_count.to_i
  end

  def title
    'Trainees Verification'
  end

  def template
    'trainees_verification'
  end

  def show_max_rows
    ENV['SHOW_MAX_ROWS'] || 10
  end

  def download_params
    report_name = self.class.name.underscore.split('_') - ['report']
    report_name = report_name.join('_')
    { report_name: report_name,
      action: :show,
      id: 1 }
  end
end
