# frozen_string_literal: true

class EmployerSourceFactory
  class << self
    def find_or_create_employer_source(user, grant = nil)
      grant ||= current_grant

      return scoped_employer_source(user, grant) if grant.try(:scoped_employers)

      es = EmployerSource.where(name: user_source_name(user)).first

      return es if es

      es = create_employer_source(user) # keep grant_id as null

      user.default_employer_source_id = es.id
      user.save

      es
    end

    def current_grant
      Grant.current_id && Grant.find(Grant.current_id)
    end

    def scoped_employer_source(user, grant)
      es = EmployerSource.where(name: user_source_name(user, grant),
                                grant_id: grant.id).first
      return es if es

      es = create_employer_source(user, grant)

      unless user.default_employer_source_id
        user.default_employer_source_id = es.id
        user.save
      end

      es
    end

    def create_employer_source(user, grant = nil)
      es = EmployerSource.create(name: user_source_name(user, grant),
                                 grant_id: grant.try(:id))
      es.user_employer_sources.create(user_id: user.id)
      es
    end

    def user_source_name(user, grant = nil)
      return user.name unless grant

      "#{user.name}_#{grant.name}"
    end
  end
end
