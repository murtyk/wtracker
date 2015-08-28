# stores the status information for data imported from a file
# should be subclassed for each model imported
# used by importer
# failed rows get captured in import_fails
class ImportStatus < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id) }
  serialize :params
  serialize :data

  attr_accessible :file_name, :status, :rows_failed, :rows_successful,
                  :type, :user_id, :sector_ids, :klass_id, :params, :data,
                  :aws_file_name # permitted

  belongs_to :user
  belongs_to :account
  has_many :import_fails, dependent: :destroy

  delegate :name, to: :account, prefix: true

  before_save :default_values
  before_destroy :delete_aws_file

  def user_name
    user_id && User.unscoped.find(user_id).name
  end

  def get_param(attr)
    params[attr]
  end

  def default_values
    self.status ||= 'started'
  end

  def errors?
    import_fails.any?
  end

  def file_url
    aws_file_name && Amazon.file_url(aws_file_name)
  end

  def self.group_by_account
    account_import_statuses = []
    accounts = Account.all
    accounts.each do |account|
      statuses = ImportStatus.unscoped.includes(:user)
                 .where(account_id: account.id)
                 .order(created_at: :desc)
      account_import_statuses << [account, statuses] unless statuses.empty?
    end
    account_import_statuses
  end

  private

  def delete_aws_file
    Amazon.delete_file(aws_file_name) if aws_file_name
    true
  rescue => error
    logger.error "aws file, #{aws_file_name}, does not exist for delete," \
                 " will ignore: #{error}"
    return true
  end
end
