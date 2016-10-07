# decorator for trainee
# mainly used in show action
class TraineeDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end
  def land_no
    return nil unless object.land_no?
    h.format_phone_no(object.land_no) + '<br>'.html_safe
  end

  def mobile_no(skip_suffix = false)
    return nil unless object.mobile_no?
    suffix = skip_suffix ? "" : '(m)<br>'.html_safe
    h.format_phone_no(object.mobile_no) + suffix
  end

  def home_address
    return nil unless object.home_address

    formatted_address.html_safe
  end

  def formatted_address
    ['' + h.h(line1),
     h.h(city),
     "#{state} #{zip}",
     'county: <b>' + county_name.to_s + '</b>'].join('<br>') + '<br>'
  end

  def email
    return unless object.email
    (object.email + '<br>').html_safe
  end

  def funding_source
    "<p>Funding Source: #{object.funding_source_name}</p>".html_safe
  end

  def navigator
    return nil unless applicant
    'Navigator: ' + applicant.navigator_name
  end

  def files_header
    return nil unless TraineeFilePolicy.new.index?

    html = '<hr>'  \
           '<h4>'  \
           'Files ' +
           h.button_new_association(TraineeFile, trainee_id: object.id,
                                                 title: 'Add Document',
                                                 skip_policy_check: true) +
           '</h4>'
    html.html_safe
  end

  def trainee_files
    return nil unless TraineeFilePolicy.new.index?
    object.trainee_files
  end

  def assessments_header
    return nil unless Assessment.any?
    return nil unless TraineeAssessmentPolicy.new(h.current_user).index?
    html = '<h4>' \
           'Assessments ' +
           h.button_new_association(TraineeAssessment, trainee_id: id,
                                                       title: 'Add Assessment') +
           '</h4>'
    html.html_safe
  end

  def assessments
    return [] unless TraineeAssessmentPolicy.new(h.current_user).index?
    object.assessments
  end

  def trainee_assessments
    object.trainee_assessments.includes(:assessment).decorate
  end

  def trainee_submits_header
    return nil unless TraineeSubmitPolicy.new(h.current_user).index?
    html =  '<h4>' \
            'Jobs Applied ' +
            h.button_new_association(TraineeSubmit, trainee_id: id,
                                                    title: 'New Job Applied') +
            '</h4>'
    html.html_safe
  end

  def trainee_submits
    return [] unless TraineeSubmitPolicy.new(h.current_user).index?
    object.trainee_submits.includes(:employer)
  end

  def job_shares_header
    return nil unless JobSharePolicy.new(h.current_user).index?
    '<h4>Job Leads Forwarded:</h4>'.html_safe
  end

  def job_shares
    return [] unless JobSharePolicy.new(h.current_user).index?
    object.job_shares.includes(shared_jobs: :shared_job_statuses)
  end

  def trainee_interactions_header
    return nil unless TraineeInteractionPolicy.new(h.current_user).index?

    html = '<h4>' \
           'Placement Information ' +
           h.button_new_association(TraineeInteraction, trainee_id: id,
                                                        page: 'trainee_page',
                                                        title: 'New Placement') +
           '</h4>'
    html.html_safe
  end

  def trainee_interactions
    object.trainee_interactions.includes(:employer)
  end

  def klass_trainees
    object.klass_trainees.includes(klass: :college).decorate
  end

  def unemployment_status_attestation
    txt = grant.unemployment_proof_text.gsub(/\r\n/, '<br>')
    txt.gsub!('$EMPLOYMENT_STATUS$', '&emsp;' + applicant.current_employment_status)
    txt.html_safe
  end

  def ui_verification_notes
    ui_verified_notes.map do |vn|
      date = vn.created_at.to_date.to_s
      user_name = vn.user.name
      [date, user_name, vn.notes].join(":")
    end.join("; ")
  end
end
