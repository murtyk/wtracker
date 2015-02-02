# mainly for finding trainees with specific skills
class TraineeSearchService
  def self.search_by_skills(skills)
    results = []
    trainee_profiles.each do |profile|
      next unless profile.skills
      if skills.blank?
        results << build_item([], profile)
      else
        matched_skills = profile_matched_skills(profile, skills)
        results << build_item(matched_skills, profile) unless matched_skills.empty?
      end
    end
    results
  end
  def self.build_item(matched_skills, profile)
    item = OpenStruct.new
    item.skills_matched = matched_skills
    item.all_skills = profile.skills
    item.trainee = profile.trainee
    item
  end
  def self.profile_matched_skills(profile, skills)
    search_list = skills.downcase.split
    profile_skills = profile.skills.downcase
    matches = []
    search_list.each do |skill|
      matches << skill if profile_skills.include?(skill)
    end
    matches
  end
  def self.trainee_profiles
    JobSearchProfile.where(trainee_id: Trainee.pluck(:id))
  end
end
