# For applicants search.
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

  def asset_exists?(filename, extension)
    asset_pathname = "#{Rails.root}/app/assets/"
    asset_file_path = "#{asset_pathname}/#{filename}".split('.')[0]
    !Dir.glob("#{asset_file_path}.#{extension}*").empty?
  end

  def js_asset_exists?(filename)
    asset_exists?("javascripts/#{filename}", 'js')
  end

  def css_asset_exists?(filename)
    asset_exists?("stylesheets/#{filename}", 'css')
  end

  def js_asset_name(c_name, a_name)
    asset_name = "#{c_name}/#{a_name}"
    return asset_name if js_asset_exists?(asset_name)

    return nil unless a_name == 'index'

    js_index_asset(c_name)
  end

  def js_index_asset(c_name)
    asset_name = "#{c_name}/indirect_index"

    js_asset_exists?(asset_name) ? asset_name : nil
  end
end
