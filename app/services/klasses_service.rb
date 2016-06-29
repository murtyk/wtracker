# for klasses index action
class KlassesService
  attr_reader :programs_data, :user_id, :account_id, :grant_id

  def initialize(user)
    @programs_data = []
    @user_id = user.id
    @account_id = Account.current_id
    @grant_id = Grant.current_id
  end

  def metrics
    Program.all.decorate.each do |program|
      init_counts(program, user)
      data = []

      @klasses.each do |klass|
        data << [klass,
                 enrolled(klass.id),
                 placed(klass.id),
                 dropped(klass.id),
                 klass_fs_counts(klass.id)]
      end

      @programs_data << [program.name, program.id, data]
    end

    programs_data
  end

  def funding_sources_names
    funding_sources.pluck(:name)
  end

  def funding_sources
    @funding_sources ||= FundingSource.order(:name)
  end

  def build_document
    metrics

    excel_file.add_row header

    programs_data.each do |program_name, program_id, klasses_data|
      klasses_data.each do |klass_data|
        excel_file.add_row view_builder.row(program_name, program_id, klass_data)
      end
    end

    excel_file.save
  end

  def file_name
    excel_file.file_name
  end

  def file_path
    excel_file.file_path
  end

  def send_results
    Account.current_id = account_id
    Grant.current_id = grant_id

    build_document

    excel_file.send_to_user('Classes List')
    Rails.logger.info "Klasses List file sent by email to #{user.name}"
  end

  private

  def user
    @user ||= User.find(user_id)
  end

  def excel_file
    @ef ||= ExcelFile.new(user, 'trainee_data')
  end

  def header
    view_builder.header
  end

  def view_builder
    @builder ||= KlassesListViewBuilder.new(self)
  end

  def klass_link(name, id)
    "<a href='/klasses/#{id}'>#{name}</a>"
  end

  def init_counts(program, user)
    @klasses = program.user_klasses(user)
    k_ids = @klasses.map(&:id)
    klass_trainees = KlassTrainee.where(klass_id: k_ids)

    @enrolled_counts = klass_trainees.group(:klass_id).count
    @placed_counts = klass_trainees.where(status: 4).group(:klass_id).count
    @dropped_counts = klass_trainees.where(status: 3).group(:klass_id).count
  end

  def enrolled(klass_id)
    @enrolled_counts[klass_id]
  end

  def placed(klass_id)
    @placed_counts[klass_id]
  end

  def dropped(klass_id)
    @dropped_counts[klass_id]
  end

  def klass_fs_counts(klass_id)
    funding_sources.map{ |fs| fs_trainees_count(klass_id, fs.id) }
  end

  def fs_trainees_count(klass_id, fs_id)
    @fs_counts ||= KlassTrainee.joins(:trainee, :klass).group(:klass_id, :funding_source_id).count

    @fs_counts[[klass_id, fs_id]]
  end
end
