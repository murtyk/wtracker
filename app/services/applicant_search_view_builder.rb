# for building header or row for search applicants
# returns row as an array
class ApplicantSearchViewBuilder
  attr_accessor :for_xml
  def initialize(for_excel = true)
    @for_excel = for_excel
  end

  def header
    [
      'Name',
      'TAPO ID(Trainee)',
      'Applied On',
      'Email',
      'Phone No',
      'County',
      'Funding Source',
      'Source',
      'Sector',
      'Employment Status',
      'Status',
      'DOB',
      'EDP Date',
      'Assessed?',
      'Assigned to class?',
      'Unemployment Proof'
    ]
  end

  def row(applicant)
    a = applicant.decorate
    unemp_proof, unemp_link = unemployment_info(a)
    [row_data(a, unemp_proof), unemp_link]
  end

  def row_data(a, unemp_proof)
    [
      a.name,
      a.trainee_id,
      a.created_at.to_date,
      a.email,
      a.mobile_phone_number,
      a.county_name,
      a.funding_source_name,
      a.source_name,
      a.sector_name,
      a.current_employment_status,
      a.status,
      a.trainee_dob,
      a.trainee_edp_date,
      a.trainee_assessed?,
      a.trainee_assigned_to_klass?,
      unemp_proof
    ]
  end

  def unemployment_info(a)
    return [a.unemp_proof_file_name, a.unemp_proof_url] if a.unemp_proof_file
    return 'Self Certified' if a.self_certified?
  end
end
