# frozen_string_literal: true

# wrapper for trainee not placed
class TraineeNotPlaced < DelegateClass(KlassTrainee)
  def start_date
    klass.start_date.to_s
  end

  def end_date
    klass.end_date.to_s
  end

  def status
    KlassTrainee::STATUSES[super]
  end

  def notes
    trainee
      .trainee_notes
      .map { |tn| "#{tn.created_at.to_date}: #{tn.notes}" }.join('<br>')
      .html_safe
  end
end
