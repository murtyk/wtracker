# for building header or row for advanced search trainees
# includes columns based on grant type
# returns row as an array
class TraineeAdvancedSearchViewBuilder
  attr_accessor :grant, :tas, :for_xml
  def initialize(grant, tas, for_excel = true)
    @grant = grant
    @tas = tas
    @for_excel = for_excel
  end

  def header
    ['First Name', 'Last Name', 'TAPO No'] +
      h_applied_on +
      ['Status', 'Email', 'Mobile No', 'County', 'Notes'] +
      header_part_1 +
      ['Funding Source', 'Education', 'Veteran'] +
      header_part_2 +
      %w(Classes Assessment) + ['Assessment Date'] +
      tas.grant_specific_headers
  end

  def h_applied_on
    return [] unless applicant?
    ['Applied On', 'Unemployment Status', 'UI Claim Verified On', 'UI Verified Notes', 'Disabled On', 'Disabled Notes']
  end

  def header_part_1
    return [] unless applicant?
    ['Last Job Title', 'Last Salary', 'Industry']
  end

  def header_part_2
    return [] unless applicant?
    ['Skills', 'Trainee Source', 'Navigator']
  end

  def row(t)
    names(t) + [t.id] +
      applied_on(t) +
      details_1(t) +
      details_2(t) +
      details_3(t) +
      details_4(t) +
      [klasses(t), assessments(t), assessment_dates(t)] +
      tas.grant_specific_values(t)
  end

  def names(t)
    [t.first, t.last]
  end

  def applied_on(t)
    return [] unless applicant?
    [t.applied_on, t.applicant.current_employment_status,
      t.ui_claim_verified_on, t.ui_verified_notes.map(&:notes).join(";"),
      t.disabled_date, t.disabled_notes]
  end

  def details_1(t)
    notes = t.trainee_notes.map{|n| n.created_at.to_date.to_s + ": " + n.notes}.join(";")
    [t.placement_status, t.email, t.mobile_no, t.county_name, notes]
  end

  def details_2(t)
    applicant? ? [t.last_job_title, t.last_wages, t.sector_name] : []
  end

  def details_3(t)
    [t.funding_source_name, t.education, t.veteran ? 'Yes' : 'No']
  end

  def details_4(t)
    applicant? ? [t.skills, t.source, t.navigator_name] : []
  end

  def applicant?
    @applicant_grant ||= grant.trainee_applications?
  end

  def klasses(t)
    t.klasses.map(&:label_for_trainees_advanced_search).join(",")
  end

  def assessments(t)
    t.assessments.map(&:name).join("\x0A").html_safe
  end

  def assessment_dates(t)
    t.trainee_assessments.map(&:date).join("\x0A").html_safe
  end
end
