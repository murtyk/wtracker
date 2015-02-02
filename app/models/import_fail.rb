# track failed records in import of a file
class ImportFail < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }

  belongs_to :account
  belongs_to :import_status
  delegate :get_param, :importer, to: :import_status
  attr_accessible :can_retry, :error_message,
                  :geocoder_fail, :row_data, :row_no

  def retry
    @retry_success = importer.retry_import_row(self)
  end

  def retry_message
    color   = @retry_success ? 'green' : 'red'
    message = @retry_success ? 'Saved!' : 'Retry Failed'
    "<b style= 'color: #{color}'>#{message}</b>"
  end
end
