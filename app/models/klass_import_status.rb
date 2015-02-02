# captures status of import from a file
class KlassImportStatus < ImportStatus
  def importer
    KlassesImporter.new
  end

  def template_name
    'imported_klasses'
  end

  def klasses
    return [] if data.blank?
    Klass.unscoped.where(id: data)
  end
end
