include UtilitiesHelper

TRAINEE_FIELDS1 = %w(first_name last_name middle_name dob gender veteran land_no
                     mobile_no email trainee_id education ethnicity home_address:line1
                     home_address:city home_address:state home_address:zip
                     mail_address:line1 mail_address:city
                     mail_address:state mail_address:zip
                     recent_employer job_title years certifications)
# imports trainees from a file
class TraineesImporter < Importer
  def initialize(all_params = nil, current_user = nil)
    if current_user && all_params

      @klass_id = all_params[:klass_id].to_i
      fail 'class required for trainees import' unless @klass_id > 0

      params = { klass_id: @klass_id }
      file_name = all_params[:file].original_filename
      @import_status = TraineeImportStatus.create(user_id: current_user.id,
                                                  file_name: file_name,
                                                  params: params)

      super
    end
  end

  def header_fields
    TRAINEE_FIELDS1
  end

  def retry_import_row(import_fail)
    begin
      row = JSON.parse import_fail.row_data
      @klass_id = import_fail.get_param(:klass_id)
      @import_status = import_fail.import_status

      trainee = import_row(row)

      if trainee
        import_status.rows_successful += 1
        import_status.rows_failed -= 1
        import_status.save
        import_fail.destroy
      end
    rescue
      return nil
    end

    trainee
  end

  def template_name
    'imported_trainees'
  end

  private

  def import_row(row)
    trainee = grant.trainees.new
    copy_attributes(trainee, row)

    # now get addresses
    trainee.home_address    = map_home_address row
    trainee.mailing_address = map_mailing_address row

    init_races(trainee, row)

    # now get tact_three attributes
    tact_three = trainee.build_tact_three
    init_tact_three(tact_three, row)

    trainee.klass_trainees.new(klass_id: @klass_id, status: 1)

    trainee.save!

    trainee
  end

  def copy_attributes(trainee, row)
    trainee.first      = clean_field(row['first_name'])
    trainee.last       = clean_field(row['last_name'])
    trainee.middle     = clean_field(row['middle_name'])
    trainee.dob        = clean_date(row['dob'])
    trainee.gender     = map_gender(row['gender'])
    trainee.veteran    = map_veteran(row['veteran'])
    trainee.land_no    = clean_phone_no(row['land_no'] || '')
    trainee.mobile_no  = clean_phone_no(row['mobile_no'] || '')
    trainee.email      = clean_field(row['email'])
    trainee.trainee_id = clean_field(row['trainee_id'])

    trainee.funding_source_id = funding_source_id(clean_field(row['funding_source']))
  end

  def init_races(trainee, row)
    race = Race.where(name: row['ethnicity']).first
    return unless race
    trainee.trainee_races.new(race_id: race.id)
  end

  def init_tact_three(t3, row)
    t3.education_level = map_educaction(row['education'])
    t3.recent_employer = clean_field(row['recent_employer'])
    t3.job_title       = clean_field(row['job_title'])
    t3.years           = clean_field(row['years']) && clean_field(row['years']).to_i
    t3.certifications  = clean_field(row['certifications'])
  end

  def map_gender(s)
    g = (clean_field(s) || 'x').downcase[0]
    return 1 if g == 'm'
    return 2 if g == 'f'
    0
  end

  def map_home_address(row)
    address = map_address_attributes(row, 'home_address:')
    return nil unless address
    copy_address_fields(HomeAddress.new, address)
  end

  def map_mailing_address(row)
    address = map_address_attributes(row, 'mail_address:')
    return nil unless address
    copy_address_fields(MailingAddress.new, address)
  end

  def map_educaction(s)
    education = clean_field(s)
    if education
      e = Education.where(name: education).first
      return e && e.id
    end
    nil
  end

  def map_veteran(s)
    veteran = clean_field(s)
    veteran && veteran.downcase == 'x'
  end

  def klass
    Klass.find(@klass_id)
  end

  def grant
    klass.grant
  end

  def funding_source_id(fs_name)
    return nil if fs_name.blank?
    fs = FundingSource.where('name ilike ?', fs_name).first
    return nil unless fs
    fs.id
  end
end
