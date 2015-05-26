# mainly for finding trainees with specific skills
class TraineeSearchService
  # returns array of objects and new email
  # object - skills and link to trainee
  # email - addessed to matched trainees
  class << self
    def search_by_skills(skills, user)
      keywords = skills.split(',').join(' ')

      results = search_profiles(keywords).map { |profile| build_item(profile) }.compact

      trainee_email = build_email(user, results) if results.any?

      [results, trainee_email]
    end

    def search(user, params)
      return [] unless params[:filters]

      name     = params[:filters][:name]
      klass_id = params[:filters][:klass_id].to_i

      return [] if klass_id == 0 && name.blank?

      return search_by_name(user, name) unless name.blank?

      Klass.find(klass_id).trainees.order(:first, :last)
    end

    private

    def search_profiles(keywords)
      jsps = JobSearchProfile.includes(:trainee).where(trainee_id: trainee_ids)
      return jsps if keywords.blank?
      jsps.search_skills(keywords)
    end

    # since only users with admin_access can add trainees, their scope should include all
    # Nav Level 3 can only see the trainees added to classes
    def search_by_name(user, name)
      if user.admin_access?
        return Trainee.search_by_name(name)
          .order(:first, :last)
      end

      Trainee.joins(:klass_trainees)
        .where(klass_trainees: { klass_id: user.klasses.pluck(:id) })
        .search_by_name(name)
        .order(:first, :last)
    end

    def build_email(user, results)
      ids   = results.map(&:id)
      names = results.map(&:name)
      user.trainee_emails.new(trainee_ids: ids, trainee_names: names, klass_id: 0)
    end

    def build_item(profile)
      trainee = profile.trainee
      link = "<a href='/trainees/#{trainee.id}'>#{trainee.name}</a>".html_safe
      skills = profile.skills
      OpenStruct.new(trainee: link, skills: skills, id: trainee.id, name: trainee.name)
    end

    def trainee_ids
      Trainee.pluck(:id)
    end
  end
end
