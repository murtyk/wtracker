# frozen_string_literal: true

# for grants where applicants can register
# Federal govt specifies the report format
# rubocop:disable Metrics/ClassLength
class HubH1bViewBuilder
  attr_reader :start_date, :end_date, :prev_quarter_start_date, :prev_quarter_end_date

  def initialize(sd, ed)
    @start_date = sd
    @end_date = ed

    @prev_quarter_end_date = end_date - 3.months
    @prev_quarter_start_date = end_date - 6.months + 1.day
  end

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
    # ['Name',
    #  'TAPO No',
    #  'SSN',
    #  'Selective Service Status',
    #  'DOB',
    #  'Gender',
    #  'Disability',
    #  'Ethnicity Hispanic/ Latino',
    #  'American Indian or Alaska Native',
    #  'Asian',
    #  'Black or African American',
    #  'Native Hawaiian or other Pacific Islander',
    #  'White',
    #  'Veteran',
    #  'Education']
    headers['100s'].values
  end

  def header_100s_numbers
    # [nil, nil, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 113, 114]
    headers['100s'].keys.map { |k| k.to_s['nil_'] ? '' : k }
  end

  def data_100s(t)
    [t.name,
     t.id,
     trainee_id(t),
     9,
     trainee_dob(t),
     gender(t),
     9, # 105 Disability
     race(1, t), race(2, t), race(3, t), race(4, t), race(5, t), race(6, t),
     veteran(t), # 113
     education(t)]
  end

  # part 200
  def header_200s
    # 'Employment Status at Participation',
    # 'Incumbent Worker',
    # 'Underemployed Worker',
    # 'Long-term Unemployed'
    headers['200s'].values
  end

  def header_200s_numbers
    # [200, 201, 202, 204]
    headers['200s'].keys
  end

  def data_200s(t)
    ap = t.applicant
    [employment_status(ap),
     incumbent_worker(t), # 201
     under_employed(ap),
     longterm_unemployed(ap)]
  end

  # part 3
  def header_300s
    # ['Date of Program Participation',
    #  'Date of Exit',
    #  'Other Reasons for Exit',
    #  'Date of Program Completion',
    #  'Most Recent Date Received Case Management Service',
    #  'Previous Quarter Received Case Management Service',
    #  'Most Recent Date Received Assessment Services',
    #  'Previous Quarter Received Assessment Services',
    #  'Most Recent Date Received Supportive Services',
    #  'Previous Quarter Received Supportive Services',
    #  'Most Recent Date Received Specialized Participant Services',
    #  'Previous Quarter Received Specialized Services',
    #  'Most Recent Date Participated in Work Experience',
    #  'Previous Quarter Participated in Work Experience']
    headers['300s'].values
  end

  def header_300s_numbers
    headers['300s'].keys
    # [301, 302, 303, 304, 310, 311, 320, 321, 330, 331, 340, 341, 350, 351]
  end

  def data_300s(t)
    [registered_date(t), # 301
     exit_date(t), # 302
     other_reasons_for_exit(t), # 303
     program_completion_date(t), # 304
     '', # 310
     '', # 311  0 if prev quarter
     assessment_date(t), # 320
     assessement_in_prev_quarter(t),
     '', # 330
     '', # 331 should be blank
     recent_service_date(t), # 340
     received_service_in_prev_quarter(t), # 341
     recent_work_exp_data(t), # 350
     work_exp_in_prev_quarter(t)]
  end

  # part 4
  def header_400s
    # [
    #   'Date Entered/Began Receiving Education/Job Training Activities #1',
    #   'Occupational Skills Training Code  #1',
    #   'Type of Training Service #1 - Primary',
    #   'Type of Training Service #1 - Secondary',
    #   'Type of Training Service #1 - Tertiary',
    #   'Date Completed, or Withdrew from, Training #1',
    #   'Training Completed #1',
    #   'Date Entered/Began Receiving Education/Job Training Activities #2',
    #   'Occupational Skills Training Code  #2',
    #   'Type of Training Service #2 - Primary',
    #   'Type of Training Service #2 - Secondary',
    #   'Type of Training Service #2 - Tertiary',
    #   'Date Completed, or Withdrew from, Training #2',
    #   'Training Completed #2',
    #   'Date Entered/Began Receiving Education/Job Training Activities #3',
    #   'Occupational Skills Training Code  #3',
    #   'Type of Training Service #3 - Primary',
    #   'Type of Training Service #3 - Secondary',
    #   'Type of Training Service #3 - Tertiary',
    #   'Date Completed, or Withdrew from, Training #3',
    #   'Training Completed #3'
    # ]
    headers['400s'].values
  end

  def header_400s_numbers
    # [400, 401, 402, 403, 404, 405, 406, 410, 411, 412, 413, 414, 415,
    #  416, 420, 421, 422, 423, 424, 425, 426]
    headers['400s'].keys
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def data_400s(t)
    # training_dates = date_receiving_class_or_job_training(t)
    # end_dates = training_end_dates(t)

    tds = training_dates_and_status(t)
    codes = training_service_codes(t)

    [tds[0].try(:start_date), # 400
     '',
     codes[0], # 402
     '',
     '',
     tds[0].try(:end_date), # 405
     tds[0].try(:status), # 406
     tds[1].try(:start_date), # 410
     '', # 411
     codes[1], # 412
     '',
     '',
     tds[1].try(:end_date), # 415
     tds[1].try(:status), # 416
     tds[2].try(:start_date), # 420
     '', # 421
     codes[2], # 422
     '',
     '',
     tds[2].try(:end_date), # 425
     tds[2].try(:status)]
  end

  # part 5
  def header_500s
    # 'Employed in 1st Quarter After Program Completion',
    # 'Occupational Code',
    # 'Entered Training-Related Employment',
    # 'Retained Current Position',
    # 'Advanced into a New Position with Current Employer in the
    #       1st Quarter after Completion',
    # 'Retained Current Position in the 2nd Quarter after Program Completion',
    # 'Advanced into a New Position with Current Employer in the
    #       2nd Quarter after Program Completion',
    # 'Retained Current Position in the 3rd Quarter After Program Completion',
    # 'Advanced into a New Position with Current Employer in the
    #       3rd Quarter after Program Completion'
    headers['500s'].values
  end

  def header_500s_numbers
    # [501, 502, 503, 504, 505, 514, 515, 524, 525]
    headers['500s'].keys
  end

  def data_500s(t)
    [hired_or_ojt_completed_data(t),
     '',
     ojt_completed_start_date(t),
     '', '', '', '', '', '']
  end

  def header_600s
    # 'Type of Recognized Credential #1',
    # 'Date Attained Recognized Credential #1',
    # 'Type of Recognized Credential #2',
    # '#Date Attained Recognized Credential #3',
    # '# Type of Recognized Credential #3',
    # '# Date Attained Recognized Credential #3'
    headers['600s'].values
  end

  def header_600s_numbers
    # [601, 602, 611, 612, 621, 622]
    headers['600s'].keys
  end

  def data_600s(t)
    certs = certificates(t)
    [
      certs.try(:[], 0).try(:[], 0), # 601
      certs.try(:[], 0).try(:[], 1), # 602
      certs.try(:[], 1).try(:[], 0), # 611
      certs.try(:[], 1).try(:[], 1),
      certs.try(:[], 2).try(:[], 0),
      "'#{certs.try(:[], 2).try(:[], 1)}" # special ' for 622
    ]
  end

  # 101
  def trainee_id(t)
    return '999999999' if t.trainee_id.blank?

    t.trainee_id.gsub(/\D/, '')
  end

  def trainee_dob(t)
    return '19900101' unless t.dob

    f_date(t.dob)
  end

  # 104
  def gender(t)
    t.gender || '9'
  end

  # 106 to 111
  def race(n, t)
    @ethnicities ||= config['ethnicities'].values

    race_n = @ethnicities[n]
    race_id = race_ids[race_n]
    t.race_id == race_id ? 1 : 0
  end

  def race_ids
    @race_ids ||= Hash[Race.pluck(:name, :id).to_a]
  end

  # 113
  def veteran(t)
    t.veteran ? 2 : 0
  end

  # 114
  def education(t)
    @educations ||= config['educations']
    @educations[t.education]
  end

  # 200
  def employment_status(ap)
    return 1 if incumbent_worker(ap.trainee) == 1

    @employment_status_codes ||= config['employment_status_codes']
    @employment_status_codes[ap.current_employment_status]
  end

  # 201
  def incumbent_worker(t)
    incumbent?(t) ? 1 : 0
  end

  def incumbent?(t)
    t.applicant.employment_status_pre_selected?
  end

  # 202
  def under_employed(ap)
    return 0 if incumbent_worker(ap.trainee) == 1

    ap.current_employment_status.index('Underemployed') ? 1 : 0
  end

  # 204
  def longterm_unemployed(ap)
    return 0 if incumbent_worker(ap.trainee) == 1

    ap.current_employment_status == 'Unemployed - 6 Months or more' ? 1 : 2
  end

  # 301 Take earliest date of registration, classes, assessments and edp
  def registered_date(t)
    dates = [t.applicant.created_at.to_date]
    dates += all_klasses(t).map(&:start_date)
    dates += t.trainee_assessments.map(&:date)
    dates << t.edp_date if t.edp_date
    dates << ojt_start_date(t) if ojt_start_date(t)
    dates << hired_start_date(t) if hired_start_date(t) && !ojt_start_date(t)
    f_date(dates.compact.min)
  rescue StandardError => e
    Rails.logger.error("registered_date: trainee_id: #{t.id} error: #{e}")
    e.to_s
  end

  # 302
  # do not include disabled date
  def exit_date(t)
    # if date is there in 501 then same date should be in 302
    dt = hired_or_ojt_completed_data(t)
    return dt unless dt.blank?

    return '' unless incumbent?(t)

    # end date of incumbent training, same as 405.
    trainings = non_ws_trainings(t)
    trainings.any? ? trainings.first.end_date : ''
  end

  # 303
  def other_reasons_for_exit(t)
    exit_date(t).blank? ? '' : '0'
  end

  # 304 latest of OJT completion date and Non WS classes end date
  # should be blank OJT terminated or did not complete a class
  def program_completion_date(t)
    dates = [ojt_completed_date(t)]
    dates += non_ws_completed_klasses(t).map(&:end_date)
    max_date = dates.compact.select { |d| d <= end_date }.max
    max_date && f_date(max_date)
  rescue StandardError => e
    Rails.logger.error("program_completion_date: trainee_id: #{t.id} error: #{e}")
    e.to_s
  end

  # 320
  # take all assessments irrespective of quarter and pick the most recent
  def assessment_date(t)
    dates = t.trainee_assessments.map(&:date).compact
    f_date(dates.max)
  rescue StandardError => e
    Rails.logger.error("assessment_date: trainee_id: #{t.id} error: #{e}")
    e.to_s
  end

  # 321     1 (Yes)  or    0 (No)
  def assessement_in_prev_quarter(t)
    return '' unless assessment_date(t)

    t.trainee_assessments.each do |ta|
      return 1 if ta.date &&
                  ta.date >= prev_quarter_start_date &&
                  ta.date <= prev_quarter_end_date
    end
    0
  end

  # 340 Latest of edp, WS class end dates
  def recent_service_date(t)
    dates = ws_klasses(t).map(&:end_date)
    dates << t.edp_date if t.edp_date
    max_date = dates.compact.select { |d| d <= end_date }.max
    return f_date(max_date) if max_date

    active?(t) ? quarter_end_date : ''
  rescue StandardError => e
    Rails.logger.error("recent_service_date: trainee_id: #{t.id} error: #{e}")
    e.to_s
  end

  # 341 '', 1 or 0
  def received_service_in_prev_quarter(t)
    return '' if recent_service_date(t).blank?

    dates = ws_klasses(t).map(&:end_date)
    dates << t.edp_date if t.edp_date
    dates.compact.each do |d|
      return 1 if d >= prev_quarter_start_date &&
                  d <= prev_quarter_end_date
    end
    0
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # 350
  def recent_work_exp_data(t)
    dt = ojt_completed_date(t)
    dt ||= t.termination_date if t.terminated? && t.termination_interaction.ojt_enrolled?

    return f_date(dt) if dt && dt <= end_date

    dt || t.ojt_enrolled? ? quarter_end_date : ''
  end

  # 351  '', 1 or  0
  def work_exp_in_prev_quarter(t)
    return '' if recent_work_exp_data(t).blank?

    dt = ojt_completed_date(t)
    dt ||= t.termination_date if t.terminated? &&
                                 t.termination_interaction.ojt_enrolled?

    return 1 if dt &&
                dt >= prev_quarter_start_date &&
                dt <= prev_quarter_end_date

    0
  end

  def quarter_end_date
    f_date(end_date)
  end

  # 400, 405, 406
  # 410, 415, 416
  # 420, 425, 426
  # 400: training start date
  # 405: training end date
  # 406: 1 if training completed 0-otherwise
  #  if dropped take class end date
  def training_dates_and_status(t)
    trainings = non_ws_trainings(t)

    hi = any_ojt_interaction(t)

    return trainings unless hi

    os = OpenStruct.new(start_date: f_date(hi.start_date))
    if hi.terminated?
      os.end_date = f_date(hi.termination_date)
      os.status = 0
    elsif hi.completion_date.blank?
      return trainings
    elsif hi.completion_date <= end_date
      os.end_date = f_date(hi.completion_date)
      os.status = 1
    else
      return trainings
    end

    trainings + [os]
  end

  # helper for 405 and 302
  def non_ws_trainings(t)
    non_ws_klasses(t).map do |k|
      k_status = t.klass_trainees.where(klass_id: k.id).first.status
      status = if [2, 4, 5].include?(k_status)
                 1
               else
                 (k_status == 3 ? 0 : '')
               end

      status = '' unless k.end_date <= end_date

      k_end_date = status.blank? ? '' : k.end_date

      OpenStruct.new(start_date: f_date(k.start_date),
                     end_date: f_date(k_end_date),
                     status: status)
    end
  end

  # 402, 412, 422
  def training_service_codes(t)
    return [6, 6, 6] if t.applicant.employment_status_pre_selected?

    codes = non_ws_klasses(t).map(&:klass_category_code)

    codes << 1 if any_ojt_interaction(t)
    codes + ['', '', '']
  end
  # take Non WS class start dates and ojt enrolled date.
  # 400: first one, 410: second one 420: third one. Blank when no date available
  # def date_receiving_class_or_job_training(t)
  #   dates = non_ws_klasses(t).pluck(:start_date)
  #   dates << ojt_start_date(t)
  #   dates.compact.map{|d| f_date(d)}.sort
  # end

  # 402
  # def type_of_training_service_1(t)
  #   return 6 if t.applicant.employment_status_pre_selected?
  #   klasses = non_ws_klasses(t)
  #   if klasses.any?
  #    return klasses.first.klass_category_code
  #   end

  #   hi = any_ojt_interaction(t)
  #   hi && 1
  # end

  # take Non WS class end dates and ojt completion date.
  # 405: first one, 415: second one 425: third one. Blank when no date
  # def training_end_dates(t)
  #   dates = non_ws_klasses(t).pluck(:end_date)
  #   dates << any_ojt_completed_date(t)
  #   dates.compact.select{ |d| d <= end_date }.map{|d| f_date(d)}.sort
  # rescue StandardError => error
  #   Rails.logger.error("training_end_dates: trainee_id: #{t.id} error: #{error}")
  #   error.to_s
  # end

  # 406 and 416
  # For 406 and 416.   426 is blank.

  # Related to 400

  # Use Case 1:

  #     Class completed and OJT completed
  #     406:  1
  #     416: 1

  # Use Case 2:

  #     Class dropped and OJT completed
  #     406:  0
  #     416: 1

  # Use Case 3:

  #     Class completed and OJT terminated
  #     406: 1
  #     416: 0

  # Use Case 4:

  #     Has one of A Class Or OJT (not both)
  #     406: 1 completed 0 dropped/term
  #     416: blank

  # 406
  # def training_completed_1(t)
  #   return 0 if non_ws_dropped_klasses(t).any?
  #   return 0 if any_ojt_terminated?(t)
  #   return 1 if non_ws_completed_klasses(t).any?
  #   return 1 if any_ojt_completed_date(t)
  #   ''
  # end

  # 416
  # def training_completed_2(t)
  #   if non_ws_completed_klasses(t).any? || non_ws_dropped_klasses(t).any?
  #     return 1 if any_ojt_completed_date(t)
  #     return 0 if any_ojt_terminated?(t)
  #   end
  #   ''
  # end

  # 412: 402 takes klass code or ojt(1).
  # def type_of_training_service_2(t)
  #   return unless non_ws_klasses(t).any?

  #   hi = any_ojt_interaction(t)
  #   hi && 1
  # end

  # 501
  def hired_or_ojt_completed_data(t)
    if t.ojt_completed? && t.completion_date.try('<=', end_date)
      return f_date(t.completion_date)
    end

    t.hired? && t.start_date && t.start_date <= end_date ? f_date(t.start_date) : ''
  end

  # If there is no training activity or OJT, it should be blank.
  # If OJT completed, always 1.
  # Only if there is training activity, pull in data from TaPO.
  # 503 User will manually update
  def ojt_completed_start_date(t)
    return '' unless t.hired? || any_ojt_interaction(t)

    return 1 if ojt_completed?(t)

    case t.uses_trained_skills
    when 'Yes'
      1
    when 'No'
      0
    else
      9 # dont know
    end
  end

  # 600s
  def certificates(t)
    completed_klass_ids = non_ws_completed_klasses(t).map(&:id)
    certs = KlassCertificate.where(klass_id: completed_klass_ids)
    certs.map { |c| [c.certificate_category_code, f_date(c.klass.end_date)] }
  end

  def active?(t)
    !(t.disabled? || t.hired?)
  end

  def ws_category_ids
    @ws_category_ids ||= KlassCategory.where(code: 'WS').pluck(:id)
  end

  def all_klasses(t)
    t.klass_trainees.map(&:klass)
  end

  def ws_klasses(t)
    # t.klasses.where(klass_category_id: ws_category_ids)

    all_klasses(t).select { |k| ws_category_ids.include?(k.klass_category_id) }
  end

  def non_ws_category_ids
    @non_ws_cat_ids ||= (KlassCategory.pluck(:id) - ws_category_ids)
  end

  def non_ws_klasses(t)
    # t.klasses
    #  .where(klass_category_id: non_ws_category_ids)
    #  .where('start_date <= ?', end_date)
    #  .order(:start_date)

    all_klasses(t)
      .select { |k| non_ws_category_ids.include?(k.klass_category_id) }
      .select { |k| k.start_date <= end_date }
      .sort_by(&:start_date)
  end

  def non_ws_klasses_by_status(t, status)
    # Klass.joins(:klass_trainees)
    #      .where(klass_category_id: non_ws_category_ids)
    #      .where(klass_trainees: { trainee_id: t.id, status: status })
    #      .where('klasses.start_date <= ?', end_date)

    a_status = status.is_a?(Array) ? status : [status]

    t
      .klass_trainees
      .select { |kt| a_status.include?(kt.status) }
      .map(&:klass)
      .select { |k| non_ws_category_ids.include?(k.klass_category_id) }
      .select { |k| k.start_date <= end_date }
  end

  def non_ws_completed_klasses(t)
    non_ws_klasses_by_status(t, [2, 4, 5]).select { |k| k.end_date <= end_date }
  end

  def non_ws_dropped_klasses(t)
    non_ws_klasses_by_status(t, 3)
  end

  def ojt_interaction(t)
    # t.trainee_interactions
    #  .where(status: [5, 6], termination_date: nil)
    #  .where('start_date <= ?', end_date)
    #  .last
    t
      .trainee_interactions
      .select { |ti| [5, 6].include?(ti.status) }
      .select { |ti| ti.termination_date.nil? }
      .select { |ti| ti.start_date <= end_date }
      .last
  end

  def any_ojt_interaction(t)
    # t.trainee_interactions
    #  .where(status: [5, 6])
    #  .where('start_date <= ?', end_date)
    #  .last

    t
      .trainee_interactions
      .select { |ti| [5, 6].include?(ti.status) }
      .select { |ti| ti.start_date <= end_date }
      .last
  end

  def any_ojt_terminated?(t)
    # t.trainee_interactions
    #  .where.not(termination_date: nil)
    #  .where(status: [5, 6])
    #  .where('start_date <= ?', end_date)
    #  .last

    t
      .trainee_interactions
      .select { |ti| ti.termination_date.present? }
      .select { |ti| [5, 6].include?(ti.status) }
      .select { |ti| ti.start_date <= end_date }
      .last
  end

  # for 400, 410, 420
  def ojt_start_date(t)
    hi = any_ojt_interaction(t)
    hi.try(:start_date)
  end

  def ojt_completed_date(t)
    hi = ojt_interaction(t)
    return unless hi && hi.status == 6

    hi.completion_date
  end

  def any_ojt_completed_date(t)
    hi = any_ojt_interaction(t)
    return unless hi && hi.status == 6 && hi.completion_date.try('<=', end_date)

    hi.completion_date.blank? ? nil : hi.completion_date
  end

  def ojt_completed?(t)
    hi = ojt_interaction(t)
    return unless hi && hi.status == 6 && hi.completion_date.try('<=', end_date)

    1
  end

  def hired_start_date(t)
    return nil unless t.hired?
    return nil unless (start_date..end_date).cover?(t.start_date)

    t.start_date
  end

  # common to all parts
  def f_date(dt)
    dt.try(:strftime, '%Y%m%d')
  end

  def headers
    @headers ||= config['headers']
  end

  def config
    @config ||= YAML.load_file(yml_path)
  end

  def yml_path
    "#{Rails.root.join('config', 'locales', 'reports')}/hubh1b.yml"
  end
end
