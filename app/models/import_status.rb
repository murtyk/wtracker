# stores the status information for data imported from a file
# should be subclassed for each model imported
# used by importer
# failed rows get captured in import_fails
class ImportStatus < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }
  serialize :params
  serialize :data

  belongs_to :user
  belongs_to :account
  has_many :import_fails, dependent: :destroy

  delegate :name, to: :account, prefix: true

  before_save :default_values
  before_destroy :delete_aws_file

  def user_name
    return "no user id" unless user_id

    u = User.unscoped.where(id: user_id).first
    return "no user found for id: #{user_id}" unless u

    u.name
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
