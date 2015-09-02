# captures the status of import of trainees from a file
class TraineeUpdatesImportStatus < ImportStatus
  def importer
    TraineesImporter.new
  end

  def template_name
    'imported_trainee_updates'
  end

  def trainees
    return [] if data.blank?
    Trainee.unscoped.where(id: data).sort { |a, b| a.name <=> b.name }
  end
end
