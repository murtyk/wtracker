include UtilitiesHelper
# to build and update klass
class KlassFactory
  def self.new_klass(params)
    return nil unless params && (params[:program_id] || params[:klass])

    if params[:program_id]
      klass = Klass.new(program_id: params[:program_id])
      (1..6).each { |d| klass.klass_schedules.build(dayoftheweek: d) }
    else
      klass_params = clone_params(params)
      klass = Klass.new(klass_params)
    end

    klass
  end

  def self.update_klass(params)
    klass_params = clone_params(params)
    klass = Klass.find(params[:id])
    klass.update_attributes(klass_params)
    klass
  end

  def self.clone_params(params)
    klass_params = params[:klass].clone
    klass_params[:start_date] = opero_str_to_date(klass_params[:start_date])
    klass_params[:end_date] = opero_str_to_date(klass_params[:end_date])
    klass_params
  end
end
