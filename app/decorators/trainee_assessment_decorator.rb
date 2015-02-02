# decorator for trainee assessment
class TraineeAssessmentDecorator < Draper::Decorator
  delegate_all

  def details
    s = assessment_name
    s += "--#{score}"  if grant.assessments_include_score?
    s += "--#{status}" if grant.assessments_include_pass?
    s
  end
end
