class AutoSharedJobsCleaner
  class << self
    def clean(all = false)
      Rails.logger.info "Total Job Leads in DB: #{AutoSharedJob.count}"

      if all
        AutoSharedJob.delete_all
      else
        AutoSharedJob.where("created_at < ?", 1.month.ago).delete_all
      end

      Rails.logger.info "Current jobs count = #{AutoSharedJob.count}"
    end
  end
end
