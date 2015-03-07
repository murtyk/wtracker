# mixin methods for Job for sharing
module JobMixins
  def jobinfo
    "#{title};#{location};#{company};#{details_url}"
  end

  def jobinfo_for_share
    { title:       title,
      location:    location,
      company:     company,
      source:      source,
      date_posted: date_posted,
      excerpt:     excerpt,
      details_url: details_url }
  end
end
