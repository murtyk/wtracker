include UtilitiesHelper

EMPLOYER_FIELDS = ['company:name', 'address:line1', 'address:city', 'address:state',
                   'address:zip',  'contact1:first_name', 'contact1:last_name',
                   'contact1:land_no', 'contact1:ext', 'contact1:email']
# imports employers from a file
class EmployersImporter < Importer
  attr_reader :employers

  def initialize(all_params = nil, current_user = nil)
    return unless current_user && all_params

    @employer_source_id = all_params[:employer_source_id]
    fail 'source required for employers import' if @employer_source_id.blank?

    init_sectors(all_params[:sector_ids])

    params = { employer_source_id: @employer_source_id, sector_ids: @sector_ids }
    file_name = all_params[:file].original_filename
    @import_status = EmployerImportStatus.create(user_id: current_user.id,
                                                 file_name: file_name,
                                                 params: params)

    super
  end

  def employers
    @objects || []
  end

  def header_fields
    EMPLOYER_FIELDS
  end

  def retry_import_row(import_fail)
    begin
      row = JSON.parse import_fail.row_data
      @sector_ids = import_fail.get_param(:sector_ids)

      employer = import_row(row)

      if employer
        @import_status = import_fail.import_status
        import_status.rows_successful += 1
        import_status.rows_failed -= 1
        import_status.save
        import_fail.destroy
      end

    rescue
      return nil
    end

    employer
  end

  def template_name
    'imported_employers'
  end

  private

  def init_sectors(s_ids)
    @sector_ids = s_ids
    @sector_ids.delete('')

    sectors = Sector.where(id: @sector_ids)

    fail 'sectors required for employers import' if sectors.empty?
  end

  def import_row(row)
    employer          = Employer.new
    employer.address  = map_address_attributes row
    employer.name     = row['company:name']
    employer.phone_no = clean_phone_no(row['phone_no'])
    employer.employer_source_id = @employer_source_id

    check_duplicate(employer)

    build_contacts(employer, row)
    build_sectors(employer)

    employer.save!

    employer
  end

  def check_duplicate(employer)
    return unless employer.duplicate?
    dup_bad_address = "duplicate - #{employer.name} - with missing or invalid address"
    fail dup_bad_address if employer.address.nil?
    fail "duplicate - #{employer.name} - #{employer.city} - #{employer.state}"
  end

  def build_contacts(employer, row)
    cn = 1

    while row["contact#{cn}" + ':first_name']
      cprefix = "contact#{cn}"
      # break unless row["contact#{cn}" + ':first_name']
      c  = employer.contacts.new
      assign_contact_attributes(c, cprefix, row)
      cn += 1
    end
  end

  def build_sectors(employer)
    @sector_ids.each { |sid| employer.employer_sectors.new(sector_id: sid.to_i) }
  end

  def assign_contact_attributes(c, cprefix, row)
    c.first, c.last = contact_name_parts(row, cprefix)
    c.title     = row[cprefix + ':title']
    c.email     = row[cprefix + ':email']
    c.land_no,
    c.ext,
    c.mobile_no = contact_phone_numbers(row, cprefix)
  end

  def contact_name_parts(row, cprefix)
    [row[cprefix + ':first_name'], row[cprefix + ':last_name']]
  end

  def contact_phone_numbers(row, cprefix)
    [
      clean_phone_no(row[cprefix + ':land_no'] || ''),
      row[cprefix + ':ext'],
      clean_phone_no(row[cprefix + ':mobile_no'] || '')
    ]
  end
end
