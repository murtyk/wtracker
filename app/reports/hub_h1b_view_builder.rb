class HubH1bViewBuilder
  RACES = ['Do not wish to disclose',
           'Hispanic/Latino',
           'American Indian/Alaska Native',
           'Asian',
           'Black or African American',
           'Hawaiian Native or Other Pacific Islander',
           'White/Caucasian']

  EDUCATIONS = Hash[
    'Below High School', 10,
    'GED', 88,
    'High School Diploma', 87,
    'Some college', 90,
    'Post Secondary Credential or Certificate', 92,
    'Associate Degree', 91,
    'Bachelor Degree', 16,
    'Graduate Degree or above', 99
   ]
  EMPLOYMENT_STATUSES = Hash[
    'Unemployed - 6 Months or more', 0,
    'Part-time Employed (Underemployed for 6 months or more)', 1,
    'Underemployed (Full-time employed in unrelated field for 6 months or more)', 1,
    'Unemployed - 6 Months or Less', 0
   ]
  def th
    cols = header.map { |h| "<th>#{h}</th>" }.join('')
    "<tr>#{cols}</tr>".html_safe
  end

  def tr(t)
    row = build_row(t).map { |d| "<td>#{d}</td>" }.join('')
    "<tr>#{row}</tr>".html_safe
  end

  def header
    [header_100s, header_200s].flatten
  end

  def build_row(t)
    [data_100s(t), data_200s(t)].flatten
  end

  # part 100
  def header_100s
    ['Name',
     'SSN',
     'Selective Service Status',
     'DOB',
     'Gender',
     'Disability',
     'Ethnicity Hispanic/ Latino',
     'American Indian or Alaska Native',
     'Asian',
     'Black or African American',
     'Native Hawaiian or other Pacific Islander',
     'White',
     'Veteran',
     'Education']
  end

  def data_100s(t)
    [t.name,
     t.trainee_id,
     '',            # Selective Service Status
     f_date(t.dob),
     gender(t),
     '',            # Disability
     race(1, t),
     race(2, t),
     race(3, t),
     race(4, t),
     race(5, t),
     race(6, t),
     veteran(t),
     education(t)]
  end

  def gender(t)
    t.gender || '9'
  end

  def race(n, t)
    race_n = RACES[n]
    race_id = race_ids[race_n]
    t.race_id == race_id ? 1 : 0
  end

  def race_ids
    @race_ids ||= Hash[Race.pluck(:name, :id).to_a]
  end

  def veteran(t)
    t.veteran ? 1 : 0
  end

  def education(t)
    EDUCATIONS[t.education]
  end

  # part 200
  def header_200s
    ['Employment Status at Participation',
     'Incumbent Worker',
     'Underemployed Worker',
     'Long-term Unemployed']
  end

  def data_200s(t)
    ap = t.applicant
    [employment_status(ap), '', under_employed(ap), longterm_unemployed(ap)]
  end

  def employment_status(ap)
    EMPLOYMENT_STATUSES[ap.current_employment_status]
  end

  def under_employed(ap)
    ap.current_employment_status.index('Underemployed') ? 1 : 0
  end

  def longterm_unemployed(ap)
    ap.current_employment_status == 'Unemployed - 6 Months or more' ? 1 : 0
  end

  # common to all parts
  def f_date(dt)
    dt.try(:strftime, '%Y%m%d')
  end
end
