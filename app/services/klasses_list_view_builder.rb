# for building header or row for klasses list
# returns row as an array
class KlassesListViewBuilder
  attr_reader :ks

  def initialize(ks)
    @ks = ks
  end

  def header
    %w(Program Class College Category Certificates) +
      %w(Enrolled Placed Dropped) + ['% Placed'] +
      ks.funding_sources_names +
      ['Training hours', 'Credits', 'Start date', 'End date']
  end

  def row(program_name, _program_id, klass_data)
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
      percent_placed(enrolled_count, placed_count),
      fs_counts,
      klass.training_hours,
      klass.credits,
      klass.start_date,
      klass.end_date
    ].flatten
  end

  def percent_placed(enrolled_count, placed_count)
    ec = enrolled_count.to_i
    pc = placed_count.to_i

    return '' unless ec > 0 && pc > 0
    format('%.2f', pc * 100.0 / ec) + '%'
  end
end
