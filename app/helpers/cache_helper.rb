# for accessing cache
module CacheHelper
  def cache_id_sorted_by_score(job_search_id)
    "jobs_analyzed_sorted_by_score_#{job_search_id}"
  end

  def cache_id_analyzed(job_search_id)
    "jobs_analyzed_#{job_search_id}"
  end

  def cache_id_counties_analyzed(job_search_id)
    "jobs_county_analysis_#{job_search_id}"
  end

  def cache_id_google_places(job_search_id)
    "google_places_cache_#{job_search_id}"
  end

  def read_cache(key)
    Rails.cache.read(key)
  end

  def write_cache(key, data, expires_in)
    Rails.cache.write(key, data, expires_in: expires_in)
  end

  def cache_exist?(key)
    Rails.cache.exist?(key)
  end
end
