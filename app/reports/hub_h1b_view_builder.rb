class HubH1bViewBuilder
  attr_reader :start_date, :end_date

  def initialize(sd, ed)
    @start_date = sd
    @end_date = ed
  end

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
    cols_numbers = header_numbers.map { |h| "<th>#{h}</th>" }.join('')
    "<tr>#{cols}</tr><tr>#{cols_numbers}</tr>".html_safe
  end

  def tr(t)
    row = build_row(t).map { |d| "<td>#{d}</td>" }.join('')
    "<tr>#{row}</tr>".html_safe
  end

  def header
    [header_100s, header_200s, header_300s,
     header_400s, header_500s, header_600s].flatten
  end

  def header_numbers
    [header_100s_numbers, header_200s_numbers, header_300s_numbers,
     header_400s_numbers, header_500s_numbers, header_600s_numbers].flatten
  end

  def build_row(t)
    [data_100s(t), data_200s(t), data_300s(t),
     data_400s(t), data_500s(t), data_600s(t)].flatten
  end

  # part 100
  def header_100s
    ['Name',
     'TAPO No',
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

  def header_100s_numbers
    [nil, nil, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 113, 114]
  end

  def data_100s(t)
    [t.name,
     t.id,
     trainee_id(t),
     9,
     f_date(t.dob),
     gender(t),
     9,            # Disability
     race(1, t),
     race(2, t),
     race(3, t),
     race(4, t),
     race(5, t),
     race(6, t),
     veteran(t),
     education(t)]
  end

  def trainee_id(t)
    return '999999999' if t.trainee_id.blank?
    "'" + t.trainee_id.gsub(/\D/, '')
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
    t.veteran ? 2 : 0
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

  def header_200s_numbers
    [200, 201, 202, 204]
  end

  def data_200s(t)
    ap = t.applicant
    [employment_status(ap),
     0,
     under_employed(ap),
     longterm_unemployed(ap)]
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

  # part 3
  def header_300s
    ['Date of Program Participation',
     'Date of Exit',
     'Other Reasons for Exit',
     'Date of Program Completion',
     'Most Recent Date Received Case Management Service',
     'Previous Quarter Received Case Management Service',
     'Most Recent Date Received Assessment Services',
     'Previous Quarter Received Assessment Services',
     'Most Recent Date Received Supportive Services',
     'Previous Quarter Received Supportive Services',
     'Most Recent Date Received Specialized Participant Services',
     'Previous Quarter Received Specialized Services',
     'Most Recent Date Participated in Work Experience',
     'Previous Quarter Participated in Work Experience']
  end

  def header_300s_numbers
    [301, 302, 303, 304, 310, 311, 320, 321, 330, 331, 340, 341, 350, 351]
  end

  def data_300s(t)
    [f_date(t.applicant.created_at),
     exit_date(t),
     '',
     program_completion_date(t),
     '',
     0,
     assessment_date(t),
     0,
     '',
     0,
     klasses_end_date(t),
     0,
     recent_ojt_enrolled_date(t),
     0]
  end

  def exit_date(t)
    return '' unless t.start_date && t.start_date >= start_date && t.start_date <= end_date
    f_date(t.start_date)
  end

  def program_completion_date(t)
    hi = t.hired_employer_interaction
    return '' unless hi
    hi.status == 6 ? f_date(hi.updated_at) : ''
  end

  def klasses_end_date(t)
    return '' unless t.klasses.any?
    f_date t.klasses.map(&:end_date).compact.max
  end

  def recent_ojt_enrolled_date(t)
    hi = t.hired_employer_interaction
    return '' unless hi
    hi.status == 5 ? f_date(end_date) : ''
  end

  def assessment_date(t)
    dates = t.trainee_assessments.map do |ta|
      ta.date if ta.date && ta.date >= start_date && ta.date <= end_date
    end.compact
    f_date(dates.max)
  end

  # part 4
  def header_400s
    [
      'Date Entered/Began Receiving Education/Job Training Activities #1',
      'Occupational Skills Training Code  #1',
      'Type of Training Service #1 - Primary',
      'Type of Training Service #1 - Secondary',
      'Type of Training Service #1 - Tertiary',
      'Date Completed, or Withdrew from, Training #1',
      'Training Completed #1',
      'Date Entered/Began Receiving Education/Job Training Activities #2',
      'Occupational Skills Training Code  #2',
      'Type of Training Service #2 - Primary',
      'Type of Training Service #2 - Secondary',
      'Type of Training Service #2 - Tertiary',
      'Date Completed, or Withdrew from, Training #2',
      'Training Completed #2',
      'Date Entered/Began Receiving Education/Job Training Activities #3',
      'Occupational Skills Training Code  #3',
      'Type of Training Service #3 - Primary',
      'Type of Training Service #3 - Secondary',
      'Type of Training Service #3 - Tertiary',
      'Date Completed, or Withdrew from, Training #3',
      'Training Completed #3'
    ]
  end

  def header_400s_numbers
    [400, 401, 402, 403, 404, 405, 406, 410, 411, 412, 413, 414, 415, 416, 420, 421, 422, 423, 424, 425, 426]
  end

  def data_400s(t)
    [ojt_start_date(t),
     "'00000000",
     ojt?(t),
     '',
     '',
     ojt_completed_date(t),
     ojt_completed?(t),
     '',
     "'00000000", # 411
     '',
     '',
     '',
     '',
     '',
     '',
     "'00000000", # 421
     '',
     '',
     '',
     '',
     '']
  end

  def ojt_interaction(t)
    t.trainee_interactions
      .where(status: [5, 6])
      .where('start_date >= ?', start_date)
      .where('start_date <= ?', end_date)
      .last
  end

  def ojt_start_date(t)
    hi = ojt_interaction(t)
    hi && f_date(hi.start_date)
  end

  def ojt?(t)
    hi = ojt_interaction(t)
    hi && 1
  end

  def ojt_completed_date(t)
    hi = ojt_interaction(t)
    return '' unless hi
    hi.status == 6 ? f_date(hi.updated_at) : ''
  end

  def ojt_completed_start_date(t)
    hi = ojt_interaction(t)
    return '' unless hi
    hi.status == 6 ? f_date(hi.start_date) : ''
  end

  def ojt_completed?(t)
    hi = ojt_interaction(t)
    return '' unless hi
    hi.status == 6 ? 1 : ''
  end

  # part 5
  def header_500s
    [
      'Employed in 1st Quarter After Program Completion',
      'Occupational Code',
      'Entered Training-Related Employment',
      'Retained Current Position',
      'Advanced into a New Position with Current Employer in the 1st Quarter after Completion',
      'Retained Current Position in the 2nd Quarter after Program Completion',
      'Advanced into a New Position with Current Employer in the 2nd Quarter after Program Completion',
      'Retained Current Position in the 3rd Quarter After Program Completion',
      'Advanced into a New Position with Current Employer in the 3rd Quarter after Program Completion'
    ]
  end

  def header_500s_numbers
    [501, 502, 503, 504, 505, 514, 515, 524, 525]
  end

  def data_500s(t)
    [exit_date(t),
     "'00000000",
     ojt_completed_start_date(t),
     '',
     '',
     '',
     '',
     '',
     '']
  end

  def header_600s
    ['Type of Recognized Credential #1',
     'Date Attained Recognized Credential #1',
     'Type of Recognized Credential #2',
     '#Date Attained Recognized Credential #3',
     '# Type of Recognized Credential #3',
     '# Date Attained Recognized Credential #3']
  end

  def header_600s_numbers
    [601, 602, 611, 612, 621, 622]
  end

  def data_600s(_t)
    ['', '', '', '', '', "'"]
  end

  # common to all parts
  def f_date(dt)
    dt.try(:strftime, '%Y%m%d')
  end
end
