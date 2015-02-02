include UtilitiesHelper

EMPLOYER_FIELDS = ['company:name', 'address:line1', 'address:city', 'address:state',
                   'address:zip',  'contact1:first_name', 'contact1:last_name',
                   'contact1:land_no', 'contact1:ext', 'contact1:email']
# imports employers from a file
class EmployersImporter < Importer
  attr_reader :employers

  def initialize(all_params = nil, current_user = nil)
    return unless current_user && all_params

    @sector_ids = all_params[:sector_ids]
    @sector_ids.delete('')
    sectors = @sector_ids.any? ? Sector.where(id: @sector_ids) : []
    fail 'sectors required for employers import' if sectors.empty?

    params = { sector_ids: @sector_ids }
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

  def import_row(row)
    employer          = Employer.new
    employer.address  = map_address_attributes row
    employer.name     = row['company:name']
    employer.source   = row['source'] || 'not available'
    employer.phone_no = clean_phone_no(row['phone_no'])

    cn = 1

    while row["contact#{cn}" + ':first_name']
      cprefix = "contact#{cn}"
      # break unless row["contact#{cn}" + ':first_name']
      c  = employer.contacts.new
      import_contact(c, cprefix, row)
      cn += 1
    end

    @sector_ids.each { |sid| employer.employer_sectors.new(sector_id: sid.to_i) }

    if employer.duplicate?
      dup_bad_address = "duplicate - #{employer.name} - with missing or invalid address"
      fail dup_bad_address if employer.address.nil?
      fail "duplicate - #{employer.name} - #{employer.city} - #{employer.state}"
    end

    employer.save!

    employer
  end

  def import_contact(c, cprefix, row)
    c.first     = row[cprefix + ':first_name']
    c.last      = row[cprefix + ':last_name']
    c.title     = row[cprefix + ':title']
    c.email     = row[cprefix + ':email']
    c.land_no   = clean_phone_no(row[cprefix + ':land_no'] || '')
    c.ext       = row[cprefix + ':ext']
    c.mobile_no = clean_phone_no(row[cprefix + ':mobile_no'] || '')
  end
end
