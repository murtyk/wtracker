# captures one employer particiaption in one class event
class KlassInteraction < ActiveRecord::Base
  STATUSES = { 1 => 'Interested', 2 => 'Confirmed', 3 => 'Attended',
               4 => 'Cancelled', 5 => 'Rescheduling' }

  default_scope { where(account_id: Account.current_id) }
  default_scope { where(grant_id: Grant.current_id) }

  belongs_to :employer
  belongs_to :klass_event

  attr_accessible :status, :klass_event_id, :employer_id
  attr_accessor :from_page, :klass_id, :county_id, :sector_id

  delegate :klass, :event_date, :for_klass?, to: :klass_event

  def event_name
    klass_event.name
  end

  delegate :name, to: :employer, prefix: true
end
