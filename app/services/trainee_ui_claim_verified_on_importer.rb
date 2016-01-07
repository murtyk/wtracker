include UtilitiesHelper

TRAINEE_FIELDS = %w(tapo_id ui_claim_verified_on)

# imports trainee updates from a file
class TraineeUiClaimVerifiedOnImporter < Importer
  def initialize(all_params = nil, current_user = nil)
    return unless current_user && all_params

    file_name = all_params[:file].original_filename

    @import_status = TraineeUiClaimVerifiedOnImportStatus
                     .create(user_id: current_user.id,
                             file_name: file_name,
                             params: {})

    super
  end

  def header_fields
    TRAINEE_FIELDS
  end

  def template_name
    'imported_trainee_ui_claim_verified_on'
  end

  private

  def import_row(row)
    trainee = Trainee.find(row[:tapo_id])

    dt = row[:ui_claim_verified_on] && clean_date(row[:ui_claim_verified_on])

    if dt
      trainee.ui_claim_verified_on = dt
    else
      trainee.disabled_date = Date.today
    end

    trainee.save!

    trainee
  end
end
