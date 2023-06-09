# frozen_string_literal: true

include UtilitiesHelper

TRAINEE_FIELDS = %w[id dob_date edp_date assessment_name assessment_date
                    trainee_id].freeze

# imports trainee updates from a file
class TraineeUpdatesImporter < Importer
  def initialize(all_params = nil, current_user = nil)
    return unless current_user && all_params

    file_name = all_params[:file].original_filename

    @import_status = TraineeUpdatesImportStatus
                     .create(user_id: current_user.id,
                             file_name: file_name,
                             params: {})

    super
  end

  def header_fields
    TRAINEE_FIELDS
  end

  def template_name
    'imported_trainee_updates'
  end

  private

  def import_row(row)
    trainee = Trainee.find(row[:id])

    trainee.edp_date = clean_date(row[:edp_date]) if row[:edp_date]
    trainee.dob = clean_date(row[:dob_date]) if row[:dob_date]

    trainee.trainee_id = row[:trainee_id] if row[:trainee_id]

    init_assessement(trainee, row) if row[:assessment_name] && row[:assessment_date]

    trainee.save!

    trainee
  end

  def init_assessement(trainee, row)
    assessment = Assessment.find_by(name: row[:assessment_name])
    raise "assessment #{row[:assessment_name]} not found" unless assessment

    dt = clean_date(row[:assessment_date])
    trainee
      .trainee_assessments
      .new(assessment_id: assessment.id, date: dt)
  end
end
