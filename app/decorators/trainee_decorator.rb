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
    ''.html_safe + h.format_phone_no(object.land_no) + '(h)<br>'.html_safe
  end

  def mobile_no
    return nil unless object.mobile_no?
    ''.html_safe + h.format_phone_no(object.mobile_no) + '(m)<br>'.html_safe
  end

  def home_address
    return nil unless object.home_address

    addr = '' + h.h(line1) + '<br>' +
                h.h(city) + '<br>' +
                h.h("#{state} #{zip}") +
                '<br>county: <b>' + h.h(county_name) + '</b><br>'

    addr.html_safe
  end

  def email
    return unless object.email
    ''.html_safe + object.email + '<br>'.html_safe
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
           '<h4>'  +
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
    object.trainee_assessments.decorate
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
    object.trainee_submits
  end

  def job_shares_header
    return nil unless JobSharePolicy.new(h.current_user).index?
    '<h4>Job Leads Forwarded:</h4>'.html_safe
  end

  def job_shares
    return [] unless JobSharePolicy.new(h.current_user).index?
    object.job_shares
  end

  def trainee_interactions_header
    return nil unless TraineeInteractionPolicy.new(h.current_user).index?
    html = '<h4>' \
           'Interested Employers ' +
           h.button_new_association(TraineeInteraction, trainee_id: id,
                                                        title: 'New Employer Interest') +
          '</h4>'
    html.html_safe
  end

  def trainee_interactions_by_status
    return [] unless TraineeInteractionPolicy.new(h.current_user).index?
    object.trainee_interactions_by_status
  end

  def klass_trainees
    kts = object.klass_trainees
                .joins(:klass)
                .where(klasses: { grant_id: Grant.current_id })
    kts.decorate
  end
end
