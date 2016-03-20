class EmployerSourceService
  class << self

    def find_employer_source(user, grant = current_grant)
      return [] unless user && grant

      if grant.scoped_employers
        name = "#{user.name}_#{grant.name}"
        es = EmployerSource.where(name: name, grant_id: grant.id).first
        return es unless user.admin_or_director?
        return es || EmployerSourceFactory.create_employer_source(user, grant)
      end

      if user.default_employer_source_id
        return EmployerSource.where(id: user.default_employer_source_id).first
      end

      user.employer_sources.first
    end

    def employer_sources_for_selection(user)
      return [] unless current_grant
      return [] if current_grant.scoped_employers

      EmployerSource.where(grant_id: nil).all - user.employer_sources
    end

    def employers(user)
      return Employer.where(id: -1) unless current_grant

      es = find_employer_source(user, current_grant)

      return es.employers if current_grant.scoped_employers

      return Employer if user.admin_access?

      Employer
      .joins(employer_source: :user_employer_sources)
      .where(employer_sources: { grant_id: nil })
      .where(user_employer_sources: { user_id: user.id })
    end

    def current_grant
      @current_grant ||= Grant.current_id && Grant.find(Grant.current_id)
    end

    def scoped_employer_source(user, grant)
      EmployerSource
        .joins(:user_employer_sources)
        .where(grant_id: grant.id)
        .where(user_employer_sources: { user_id: user.id })
        .first
    end
  end
end
