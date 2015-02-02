# acts like a jobs database in case of instate only job search
class JobsInStateStore
  include Mongoid::Document
  include Mongoid::Timestamps::Short # For c_at and u_at.

  field :js_id, 	as: :job_search_id, type: Integer
  field :s_c, as: :state_code, type: String
  field :f, as: :searched, type: Boolean

  has_many :mongo_jobs, dependent: :delete

  def jobs(page, page_size = 25)
    mongo_jobs[(page - 1) * page_size..(page_size * page) - 1]
  end

  def get_jobs(page)
    jobs(page, 100)
  end

  def count
    mongo_jobs.count
  end

  def jobs_count
    count
  end

  def pages_count
    (count + 24) / 25
  end

  def slices_count
    1 + (count - 1) / JobSearch::JOBS_SLICE_SIZE
  end

  def save_jobs(sh_jobs)
    sh_jobs.each do |shjob|
      if shjob.location.include?(state_code)
        j_hash = shjob_to_hash(shjob)
        j_hash[:job_search_id] = job_search_id
        mongo_jobs.create(j_hash)
      end
    end
    self.searched = true
    save
  end

  private

  def shjob_to_hash(shjob)
    j_hash = {}
    attrs = [:title, :excerpt, :location, :company, :source, :details_url, :date_posted]
    attrs.each { |f| j_hash[f] = shjob.send(f.to_s) }
    j_hash
  end
end
