# a job sent to trainee by auto leads
class AutoSharedJob < ActiveRecord::Base
  belongs_to :account

  attr_accessible :status, :notes, :status_updated_at, :notes_updated_at

  def trainee
    Trainee.unscoped.find(trainee_id)
  end
  delegate :job_leads_count,
           :not_viewed_job_leads_count,
           :viewed_job_leads_count,
           :applied_job_leads_count,
           :not_interested_job_leads_count, to: :trainee

  def self.create_from_job(job, trainee)
    asj = new
    asj.account_id  = trainee.account.id
    asj.trainee_id  = trainee.id
    asj.company     = job.company
    asj.location    = job.location
    asj.title       = job.title
    asj.excerpt     = job.excerpt
    asj.date_posted = job.date_posted
    asj.url         = job.destination_url
    asj.key         = SecureRandom.urlsafe_base64(4)
    asj.save
    asj
  end

  def change_notes(new_notes)
    update_attributes(notes: new_notes, notes_updated_at: Date.today)
  end

  STATUSES = ['Not Viewed', 'Viewed', 'Applied',
              'Viewed but Not Interested', 'Not Interested']

  # viewed = 1, applied: 2, viewed_and_not_interested = 3, not_interested = 4
  STATE_MACHINE = {
    1 => { 1 => 1, 2 => 2, 4 => 3 },
    2 => { 1 => 2, 2 => 2, 4 => 2 },
    3 => { 1 => 3, 2 => 2, 4 => 3 },
    4 => { 1 => 3, 2 => 2, 4 => 4 }
  }

  def change_status(new_status)
    if status.to_i == 0
      return update_attributes(status: new_status, status_updated_at: Date.today)
    end

    next_status = STATE_MACHINE[status][new_status]

    return if status == next_status
    update_attributes(status: next_status, status_updated_at: Date.today)
  end

  def viewed?
    status && status > 0 && status < 4
  end

  def not_interested?
    status && (status == 4 || status == 3)
  end

  def applied?
    status && status == 2
  end

  def valid_key?(param_key)
    param_key == key
  end

  def status_text
    st = status.to_i
    return STATUSES[st] if st.zero?
    STATUSES[st] + ' ' + (status_updated_at || updated_at).to_date.to_s
  end

  def self.status_codes(status_param)
    return [1] if status_param == 'Viewed'
    return [2] if status_param == 'Applied'
    return [3, 4] if status_param == 'Not Interested'
    [0, nil]
  end

  def notes_label
    'Notes ' + (notes_updated_at && notes_updated_at.to_date).to_s + ':'
  end
end
