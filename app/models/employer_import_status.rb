# state of employers file import
class EmployerImportStatus < ImportStatus
  def importer
    EmployersImporter.new
  end

  def template_name
    'imported_employers'
  end

  def employers
    return [] if data.blank?
    Employer.unscoped.where(id: data)
  end
end
