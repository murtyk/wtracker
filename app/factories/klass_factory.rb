include UtilitiesHelper
# to build and update klass
class KlassFactory
  def self.new_klass(program_id)
    klass = Klass.new(program_id: program_id)
    (1..6).each { |d| klass.klass_schedules.build(dayoftheweek: d) }
    klass
  end

  def self.build_klass(params)
    klass_params = params.clone
    format_dates klass_params
    klass = Klass.new(klass_params)

    klass
  end

  def self.update_klass(id, params)
    klass_params = params.clone
    format_dates klass_params
    klass = Klass.find(id)
    klass.update_attributes(klass_params)
    klass
  end

  def self.format_dates(klass_params)
    klass_params[:start_date] = opero_str_to_date(klass_params[:start_date])
    klass_params[:end_date] = opero_str_to_date(klass_params[:end_date])
  end
end
