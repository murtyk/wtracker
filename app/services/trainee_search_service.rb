# mainly for finding trainees with specific skills
class TraineeSearchService
  # returns array of objects and new email
  # object - skills and link to trainee
  # email - addessed to matched trainees
  class << self
    def search_by_skills(skills, user)
      search_list = skills.downcase.split
      results = trainees_with_profiles.map do |trainee|
        if search_list.empty?
          build_item(trainee)
        else
          profile = trainee.job_search_profile
          any_matches?(profile, search_list) ? build_item(trainee) : nil
        end
      end.compact

      trainee_email = build_email(user, results) if results.any?

      [results, trainee_email]
    end

    def search(user, params)
      return [] unless params[:filters]

      last_name     = params[:filters][:last_name]
      klass_id      = params[:filters][:klass_id].to_i

      return [] if klass_id == 0 && last_name.blank?

      return search_by_last_name(user, last_name) unless last_name.blank?

      Klass.find(klass_id).trainees.order(:first, :last)
    end

    private

    # since only users with admin_access can add trainees, their scope should include all
    # Nav Level 3 can only see the trainees added to classes
    def search_by_last_name(user, last_name)
      if user.admin_access?
        return Trainee.where('trainees.last ilike ?', last_name + '%').order(:first, :last)
      end

      Trainee.joins(:klass_trainees)
        .where(klass_trainees: { klass_id: user.klasses.pluck(:id) })
        .where('trainees.last ilike ?', last_name + '%')
        .order(:first, :last)
        .uniq
    end

    def build_email(user, results)
      ids   = results.map(&:id)
      names = results.map(&:name)
      user.trainee_emails.new(trainee_ids: ids, trainee_names: names, klass_id: 0)
    end

    def build_item(trainee)
      link = "<a href='/trainees/#{trainee.id}'>#{trainee.name}</a>".html_safe
      skills = trainee.job_search_profile.skills
      OpenStruct.new(trainee: link, skills: skills, id: trainee.id, name: trainee.name)
    end

    def any_matches?(profile, search_list)
      profile_skills = profile.skills.downcase
      search_list.each do |skill|
        return true if profile_skills.include?(skill)
      end
      false
    end

    def trainees_with_profiles
      Trainee.joins(:job_search_profile).includes(:job_search_profile)
        .where.not(job_search_profiles: { skills: nil })
    end
  end
end
