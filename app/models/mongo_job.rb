# frozen_string_literal: true

# used for filtering in state job search results
class MongoJob
  include Mongoid::Document
  include JobMixins

  field :js_id, as: :job_search_id, type: Integer
  field :t,     as: :title,         type: String
  field :desc,  as: :excerpt,       type: String
  field :loc,   as: :location,      type: String
  field :cp,    as: :company,       type: String
  field :src,   as: :source,        type: String
  field :url,   as: :details_url,   type: String
  field :dt,    as: :date_posted,   type: DateTime

  belongs_to :jobs_in_state_store
end
