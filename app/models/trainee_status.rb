# A trainee can have many of the user defined (through settings) statuses
# User can set one of them as default
# trainee's current status is the most recents added TraineeStatus
class TraineeStatus < ActiveRecord::Base
  default_scope { where(account_id: Account.current_id, grant_id: Grant.current_id) }
  default_scope { order(created_at: :desc) }

  attr_accessible :grant_trainee_status_id, :trainee_id, :notes
  belongs_to :account
  belongs_to :grant
  belongs_to :grant_trainee_status
  belongs_to :trainee

  delegate :name, to: :grant_trainee_status

  after_create :update_trainee
  after_destroy :revert_trainee_status

  def default?
    grant_trainee_status_id == grant.default_trainee_status_id.to_i
  end

  def display_name
    dn = "#{created_at.to_date} - #{name}"
    current_status? ? "<b>#{dn}</b>".html_safe : dn
  end

  private

  def update_trainee
    trainee.update(gts_id: grant_trainee_status_id)
  end

  # trainee status should go back to the before this ts
  def revert_trainee_status
    prev_ts = TraineeStatus.first
    trainee.update(gts_id: prev_ts.grant_trainee_status_id)
  end

  def current_status?
    grant_trainee_status_id == trainee.gts_id
  end
end
