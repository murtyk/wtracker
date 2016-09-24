include UtilitiesHelper
# mother of all impoerters
class Importer
  attr_reader :import_status, :import_status_id, :current_user_id

  def initialize(all_params = nil, _current_user = nil)
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
    return EmployersImporter.new(params, current_user) if resource == 'employers'
    return CitiesImporter.new(params, current_user)    if resource == 'cities'
    return new_trainee_importer(params, current_user) if resource == 'trainees'
    nil
  end

  def self.new_trainee_importer(params, current_user)
    if params[:ui_claim_verification]
      return TraineeUiClaimVerifiedOnImporter.new(params, current_user)
    end
    return TraineesImporter.new(params, current_user) unless params[:updates]
    TraineeUpdatesImporter.new(params, current_user)
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

    @reader = open_reader
    return false unless @reader

    @count_success = 0
    @count_fails = 0

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
    @reader = open_reader
    return unless @reader
    valid_header = (@reader.header & header_fields).size == header_fields.size
# debugger
    unless valid_header
      Rails.logger.info "file header: #{@reader.header.join("---")}"
      Rails.logger.info "header fields: #{header_fields.join("---")}"
    end
    create_import_fail_for_invalid_header unless valid_header
    close_reader
  end

  def create_import_fail_for_invalid_header
    error_message = 'Invalid Header Row.'
    import_status.import_fails.create(can_retry: false, error_message: error_message,
                                      geocoder_fail: false,
                                      row_data: @reader.header * ',')
    import_status.rows_successful = -1
    import_status.rows_failed = 1
    import_status.save
  end

  def close_reader
    @reader = nil
  end

  def open_reader
    file_url = Amazon.file_url @aws_file_name
    return false unless @import_status

    ImportFileReader.new(file_url, @original_filename)
  rescue StandardError => e
    import_status.import_fails.create(row_no: 0, can_retry: false,
                                        error_message: e.to_s,
                                        geocoder_fail: false)
    false
  end

  def import_row(_row, _skip_fail_entry = false)
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
      import_status.data = @objects.map(&:id)
    end
    import_status.save
  end

  def clean_field(s)
    return s unless s.is_a?(String)
    s = s.strip
    s.blank? ? nil : s
  end

  def clean_text(s)
    s.is_a?(Float) ? s.to_i.to_s : s.to_s
  end

  def clean_phone_no(phone_no = '')
    phone_no.is_a?(Float) ? phone_no.to_i.to_s : phone_no.to_s
  end

  PLEASE_CORRECT = ' Please correct the file and upload again.'
  def clean_state(s)
    fail 'State can not be null.' + PLEASE_CORRECT unless s
    fail 'State should be 2 chars.' + PLEASE_CORRECT unless s.length == 2
    s
  end

  def clean_zip(zip)
    return nil if zip.blank?
    zip = zip.to_i.to_s if zip.is_a? Float
    zip = zip.to_s.delete('^0-9')
    zip = '0' * (5 - zip.size) + zip if zip.size < 5
    zip
  end

  def clean_date(dt)
    dt.is_a?(Date) ? dt : opero_str_to_date(clean_field(dt))
  end

  def map_address_attributes(params, prefix = 'address:')
    return nil unless params["#{prefix}city"] && params["#{prefix}state"]

    zip = clean_zip(params["#{prefix}zip"])
    oneline_address = [params["#{prefix}line1"], params["#{prefix}city"],
                       params["#{prefix}state"], zip].join(',')
    a = GeoServices.parse(oneline_address)
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
end
