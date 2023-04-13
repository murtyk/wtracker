# frozen_string_literal: true

# metrics on trainee skills specified in job search profile
class SkillMetrics
  attr_reader :metrics, :top_skills

  def generate
    metrics_hash = Hash.new(0) # 0 is default value
    profiles.each do |profile|
      next if profile.skills.blank?

      skills = parse_skills(profile.skills)
      skills.each { |skill| metrics_hash[skill] += 1 }
    end
    @metrics = metrics_hash.keys.sort.map { |k| [k, metrics_hash[k]] }
    generate_top_skills
    self
  end

  def parse_skills(skills)
    skills = skills.downcase.gsub(' and ', ',')
    skills = skills.gsub(/[^,0-9a-z ]/i, ',')
    skills.split(',').map { |kw| kw.blank? ? nil : kw.squish }.compact.uniq
  end

  def generate_top_skills
    @top_skills = []
    return metrics if metrics.size < 20

    count = top_count
    metrics.each { |m| @top_skills << m if m[1] >= count }
    @top_skills.sort! { |a, b| b[1] <=> a[1] }
  end

  def profiles
    JobSearchProfile.where(trainee_id: Trainee.pluck(:id))
  end

  def top_count
    metrics.map { |m| m[1] }.sort.reverse[9]
  end
end
