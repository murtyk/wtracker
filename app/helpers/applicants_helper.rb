module ApplicantsHelper
  def applicant_counties_for_selection
    applicant_county_counts.map do |(id, name, code), count|
      ["#{name}-#{code} (#{count})", id]
    end
  end

  def applicant_sectors_for_selection
    applicant_sector_counts.map do |(id, name), count|
      ["#{name} (#{count})", id]
    end
  end

  def applicant_sources_for_selection
    Applicant.pluck(:source).uniq.sort
  end

  def applicant_county_counts
    Applicant.joins(county: :state)
             .group('counties.id', 'counties.name', 'states.code')
             .count
  end

  def applicant_sector_counts
    Applicant.joins(:sector)
             .group('sectors.id', 'sectors.name')
             .count
  end

end