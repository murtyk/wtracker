# frozen_string_literal: true

# job titles and/or skill key words for
# searching jobs relevant to a class
class KlassTitle < ApplicationRecord
  default_scope { where(account_id: Account.current_id) }
  belongs_to :account
  belongs_to :klass
  delegate :line1, :city, :county, :state, :zip, to: :klass

  has_one :job_search

  validates :title, presence: true, length: { minimum: 3 }

  def get_job_search(refresh = false)
    return job_search if !refresh && valid_job_search_count?

    address = klass.address
    count = JobBoard.job_count(title, address.city, address.state, 25, 30)
    return create_job_search(count) unless job_search

    job_search.update_attributes(count: count)
    job_search
  end

  def jobs_count
    job_search.count
  end

  def valid_job_search_count?
    job_search && ((Time.now - job_search.updated_at) / 12.hours) < 1
  end

  def create_job_search(count)
    js = JobSearch.new(
      klass_title_id: id, keywords: title,
      location: "#{city},#{state}",
      distance: 25, days: 30, count: count
    )

    js.save

    self.job_search = js
  end
end
