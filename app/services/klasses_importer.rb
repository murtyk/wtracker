include UtilitiesHelper

KLASS_FIELDS =  %w(name description start_date end_date credits training_hours)
# imports klasses from a file
class KlassesImporter < Importer
  attr_reader :klasses, :program_id, :college_id

  def initialize(all_params = nil, current_user = nil)
    return unless current_user && all_params

    init_program_college(all_params)

    fail 'program and college required for trainees import' unless college && program

    params = { program_id: @program_id, college_id: @college_id }
    file_name = all_params[:file].original_filename
    @import_status = KlassImportStatus.create(user_id: current_user.id,
                                              file_name: file_name, params: params)

    super
  end

  def init_program_college(params)
    @program_id = params[:program_id].to_i
    @college_id = params[:college_id].to_i
  end

  def program
    Program.find(@program_id) if @program_id > 0
  end

  def college
    College.find(@college_id) if @college_id > 0
  end

  def header_fields
    KLASS_FIELDS
  end

  def klasses
    @objects || []
  end

  def template_name
    'imported_klasses'
  end

  private

  def import_row(row)
    klass = program.klasses.new
    assign_klass_attributes(klass, row)
    build_klass_schedules(klass)

    klass.save!

    klass
  end

  def assign_klass_attributes(klass, row)
    klass.name = clean_field(row['name'])
    klass.description = clean_field(row['description'])
    klass.credits = row['credits']
    klass.training_hours = row['training_hours']
    klass.college = college
    assign_klass_dates(klass, row)
  end

  def assign_klass_dates(klass, row)
    klass.start_date = clean_date(row['start_date'])
    klass.end_date = clean_date(row['end_date'])
  end

  def build_klass_schedules(klass)
    (1..6).each { |d| klass.klass_schedules.build(dayoftheweek: d) }
  end
end
