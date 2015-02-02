# status of cities file import
class CityImportStatus < ImportStatus
  def importer
    CityImporter.new
  end

  def template_name
    'cities_imported'
  end

  def cities
    return [] if data.blank?
    City.where(id: data)
  end
end
