# for reading data records from excel file
class ImportFileReader
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
      @header = @spreadsheet.row(1).map(&:downcase)
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
      return row.with_indifferent_access
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
