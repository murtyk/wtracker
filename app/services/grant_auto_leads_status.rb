# Compiles status for a job leads
class GrantAutoLeadsStatus
  attr_reader :grant, :lead_counts, :total_leads

  class << self
    def perform(grant_id)
      grant = Grant.unscoped.find(grant_id)
      Account.current_id = grant.account_id
      Grant.current_id = grant.id
      GrantAutoLeadsStatus.new(grant).perform
    end
  end

  def initialize(grant)
    @grant = grant
    @lead_counts = []
    @total_leads = 0
  end

  def perform
    build_lead_counts
    GrantJobLeadCount.create(sent_on: Date.today, count: total_leads)
    JobLeadsStatusMailer.notify(grant, lead_counts).deliver_now
    clear_cache
  end

  # rubocop:disable AbcSize
  def build_lead_counts
    result_set.each do |record|
      key = "g#{grant.id}_#{record['id']}"
      count = Rails.cache.read(key)
      next unless count

      lead_counts << record['first'] + ' ' + record['last'] + ' - ' + count.to_s
      @total_leads += count
    end
  end

  def clear_cache
    result_set.each do |record|
      key = "g#{grant.id}_#{record['id']}"
      count = Rails.cache.read(key)
      Rails.cache.delete(key) if count
    end
  end

  def sql_trainees
    <<-SQL
      SELECT ID, FIRST, LAST FROM TRAINEES
      WHERE ACCOUNT_ID = #{grant.account_id}
      AND GRANT_ID = #{grant.id}
    SQL
  end

  def result_set
    @result_set ||= ActiveRecord::Base.connection.execute(sql_trainees)
  end
end
