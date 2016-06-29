# for building header or row for klasses list
# returns row as an array
class KlassesListViewBuilder
  attr_reader :ks

  def initialize(ks)
    @ks = ks
  end

  def header
    ['Program', 'Class', 'College', 'Category', 'Certificates'] +
    ['Enrolled', 'Placed', 'Dropped'] +
    ks.funding_sources_names +
    ['Training hours', 'Credits', 'Start date', 'End date']
  end

  def row(program_name, program_id, klass_data)
    klass, enrolled_count, placed_count, dropped_count, fs_counts = klass_data

    [
      program_name,
      klass.name,
      klass.college_name,
      klass.klass_category_name,
      klass.certificate_names,
      enrolled_count,
      placed_count,
      dropped_count,
      fs_counts,
      klass.training_hours,
      klass.credits,
      klass.start_date,
      klass.end_date
    ].flatten
  end
end
