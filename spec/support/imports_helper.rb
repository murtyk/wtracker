# frozen_string_literal: true

# Importer spec guidelines
#   Just focus on testing the Importer Class for the resource
#   Take a look at ui_claim_verification_spec
#   So, do an unit spec rather than feature spec
# TODO: convert other import specs (klasses, trainees etc) to the new approach
module ImportsHelper
  class MockImportFile
    def original_filename
      'original_filename'
    end
  end

  class MockFileReader
    attr_reader :header, :rows, :index, :count

    def initialize(header, rows)
      @header = header
      @rows = rows
      @count = @rows.count
      @index = -1
    end

    def next_row
      @index += 1
      return nil unless index < count

      row = Hash[[header, rows[index]].transpose]
      row.with_indifferent_access
    end
  end

  def stub_importer_file_reader(header, rows)
    allow(Amazon).to receive(:store_file).and_return('aws_file_name')
    allow_any_instance_of(Importer).to receive(:open_reader).and_return(MockFileReader.new(
                                                                          header, rows
                                                                        ))
  end

  def build_importer_params(resource, arg)
    params = { resource: resource, file: MockImportFile.new }
    params[arg.to_sym] = true if arg
    params
  end

  def visit_new_importer(resource, arg = nil)
    url = "/import_statuses/new?resource=#{resource}"
    url += "&#{arg}=true" if arg
    visit url
  end

  def visit_show_import_status
    visit "/import_statuses/#{ImportStatus.unscoped.last.id}"
  end
end
