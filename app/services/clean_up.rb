# frozen_string_literal: true

# cleans up temp files. ex: imported data files saved on s3
class CleanUp
  def perform
    ImportStatus.unscoped.where('created_at < ?', 2.months.ago).destroy_all
  end
end
