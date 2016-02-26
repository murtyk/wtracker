include UtilitiesHelper

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
    %w(tapo_id ui_claim_verified_on funding_source disable)
  end

  def template_name
    'imported_trainee_ui_claim_verified_on'
  end

  private

  def import_row(row)
    trainee = Trainee.find(row[:tapo_id])

    dt = row[:ui_claim_verified_on] && clean_date(row[:ui_claim_verified_on])
    trainee.ui_claim_verified_on = dt if dt

    trainee.disabled_date = disabled_on(row)

    fs_id = funding_source_id(row[:funding_source])
    trainee.funding_source_id = fs_id if fs_id

    trainee.save!

    trainee
  end

  def disabled_on(row)
    disabled = row[:disable].downcase == 'yes'

    disabled ? Date.today : nil
  end

  def funding_source_id(fs_name)
    return nil if fs_name.blank?
    FundingSource.find_by(name: fs_name).try(:id)
  end
end
