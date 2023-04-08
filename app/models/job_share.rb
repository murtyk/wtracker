# captures the information of jobs sent to trainees
class JobShare < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }

  attr_accessor :to_ids, :klass_id, :js_company, :job_ids

  delegate :found, :county, :marker, :circles, to: :js_company
  alias_attribute(:company_name, :company)

  has_many :job_shared_tos, dependent: :destroy
  has_many :trainees, -> { order(:first, :last) }, through: :job_shared_tos
  has_many :shared_jobs, dependent: :destroy

  def shared_by
    from_user.name
  end

  def from_user
    User.find(from_id)
  end

  def sent_to_emails
    job_shared_tos.map(&:sent_to_email)
  end

  def self.search(filters)
    return [] unless filters
    klass_id = filters[:klass_id].to_i
    trainee_id = filters[:trainee_id].to_i
    return [] unless trainee_id > 0 || klass_id > 0
    return search_by_trainee_id(trainee_id) if trainee_id > 0
    search_by_klass_id(klass_id)
  end

  def self.search_by_trainee_id(trainee_id)
    joins(:trainees)
      .where(trainees: { id: trainee_id })
      .order('created_at desc')
  end

  def self.search_by_klass_id(klass_id)
    joins(trainees: :klass_trainees)
      .where(klass_trainees: { klass_id: klass_id })
      .order('job_shares.created_at desc').distinct
  end

  def map
    {
      markers: { data: marker.to_json },
      circles: { data: circles.to_json },
      map_options: { auto_zoom: false, zoom: 9, raw: '{scaleControl: true}' }
    }
  end
end
