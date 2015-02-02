include UtilitiesHelper
# mother of all impoerters
class Importer
  attr_reader :import_status, :import_status_id

  def initialize(all_params = nil, current_user = nil)
    @aws_file_name = Amazon.store_file(all_params[:file], 'imports')
    @original_filename = all_params[:file].original_filename
    @account_id = Account.current_id
    @grant_id = Grant.current_id
    @import_status_id = @import_status.id # subclass creates import_status
    @import_status.update(aws_file_name: @aws_file_name)
    validate_header
  end

  def self.new_importer(params, current_user = nil)
    resource  = params[:resource]
    return KlassesImporter.new(params, current_user)   if resource == 'klasses'
    return TraineesImporter.new(params, current_user)  if resource == 'trainees'
    return EmployersImporter.new(params, current_user) if resource == 'employers'
    return CitiesImporter.new(params, current_user)    if resource == 'cities'
    nil
  end

  def errors?
    import_status.import_fails.any?
  end

  def import_fails
    import_status.import_fails.order('row_no')
  end

  def import
    Account.current_id = @account_id
    Grant.current_id = @grant_id
    init_import_status
    return false unless open_reader

    import_data_rows

    update_status('completed')
  end

  def header_fields
    fail 'subclass has to implement header_fields method'
  end

  def template_name
    fail 'subclass has to implement template_name method'
  end

  def import_status
    @import_status || ImportStatus.find(import_status_id)
  end

  def init_import_status
    @import_status ||= ImportStatus.find(import_status_id)
  end

  private

  def import_data_rows
    @objects = []
    row_no = 1
    while (row = @reader.next_row)
      row_no += 1
      begin
        obj = import_row(row)
        if obj
          @objects.push obj
          @count_success += 1
        else
          @count_fails += 1
        end
      rescue StandardError => e
        store_error(row, row_no, e.to_s)
        @count_fails += 1
      end
      update_status
    end
  end

  def validate_header
    return unless open_reader
    valid_header = (@reader.header & header_fields).size == header_fields.size
    unless valid_header
      error_message = 'Invalid Header Row.'
      import_status.import_fails.create(can_retry: false, error_message: error_message,
                                        geocoder_fail: false,
                                        row_data: @reader.header * ',')
      import_status.rows_successful = -1
      import_status.rows_failed = 1
      import_status.save
    end
    close_reader
  end

  def close_reader
    @reader = nil
  end

  def open_reader
    file_url = Amazon.file_url @aws_file_name
    return false unless @import_status
    begin
      @reader = FileReader.new(file_url, @original_filename)
    rescue StandardError => e
      import_status.import_fails.create(row_no: 0, can_retry: false,
                                        error_message: e.to_s,
                                        geocoder_fail: false)
      return false
    end
    @count_success = 0
    @count_fails = 0
  end

  def import_row(row, skip_fail_entry = false)
    fail 'subclass should implement import_row'
  end

  def store_error(row, row_no, error_message)
    can_retry = error_message.include?('Geocoding')
    error_message = error_message[0..254] if error_message.length > 255
    import_status.import_fails.create(row_no: row_no, can_retry: can_retry,
                                      error_message: error_message,
                                      geocoder_fail: can_retry, row_data: row.to_json)
  end

  def update_status(status = 'processing')
    import_status.rows_successful = @count_success
    import_status.rows_failed = @count_fails
    import_status.status = status
    if status == 'completed' && !@objects.empty?
      import_status.data = @objects.map { |obj| obj.id }
    end
    import_status.save
  end

  def clean_field(s)
    if s && s.is_a?(String)
      s = s.strip
      s = nil if s.length == 0
    end
    s
  end

  def clean_phone_no(phone_no = '')
    phone_no.is_a?(Float) ? phone_no.to_i.to_s : phone_no.to_s
  end

  PLEASE_CORRECT = ' Please correct the file and upload again.'
  def clean_state(s)
    fail 'State can not be null.' + PLEASE_CORRECT unless s
    fail 'State should 2 be chars.' + PLEASE_CORRECT unless s.length == 2
    s
  end

  def clean_zip(zip)
    return nil if zip.blank?
    zip = zip.to_i.to_s if zip.class == Float
    zip = zip.to_s.delete('^0-9')
    zip = '0' * (5 - zip.size) + zip if zip.size < 5
    zip
  end

  def clean_date(dt)
    dt.class == Date ? dt : opero_str_to_date(clean_field(dt))
  end

  def map_address_attributes(params, prefix = 'address:')
    return nil unless params["#{prefix}city"] && params["#{prefix}state"]

    zip = clean_zip(params["#{prefix}zip"])
    oneline_address = [params["#{prefix}line1"], params["#{prefix}city"],
                       params["#{prefix}state"], zip].join(',')
    a = GeoServices.parse(oneline_address, zip)
    # debugger
    a.line1 ||= params["#{prefix}line1"] if a.county
    a
  end

  def copy_address_fields(a, b)
    # %w[line1 city state zip].each { |attr| a.send("#{attr}=", b.send(attr)) }
    a.line1   = b.line1
    a.city    = b.city
    a.state   = b.state
    a.zip     = b.zip
    a
  end

  def valid_float(s)
    true if Float(s) rescue false
  end

  def valid_integer(s)
    true if Integer(s) rescue false
  end

  # import file reader
  class FileReader
    attr_reader :header

    def initialize(file, file_name)
      extension = File.extname(file_name).downcase
      if extension.downcase == '.csv'
        @file_type = :CSV
        @csv = CSV.open(open(file), 'rb', headers: true,
                                          return_headers: true, row_sep: :auto)
        @header = @csv.shift.to_hash.values
      else
        @file_type = :EXCEL
        @spreadsheet = open_spreadsheet(file, file_name)
        @header = @spreadsheet.row(1)
        @next_row = 2
      end
    end

    def next_row
      if @file_type == :CSV
        r = @csv.shift
        return r && r.to_hash
      elsif @next_row <= @spreadsheet.last_row
        row = Hash[[@header, @spreadsheet.row(@next_row)].transpose]
        @next_row += 1
        return row
      end
      nil
    end

    def open_spreadsheet(file, file_name)
      case File.extname(file_name)
      when '.xls' then Roo::Excel.new(file.to_s, nil, :ignore)
      when '.xlsx' then Roo::Excelx.new(file.to_s, packed: nil, file_warning: :ignore)
      else fail "Invalid file type: #{file_name}"
      end
    end
  end
end
