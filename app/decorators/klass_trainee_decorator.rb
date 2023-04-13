# frozen_string_literal: true

# decorator for klass trainee
class KlassTraineeDecorator < Draper::Decorator
  delegate_all

  attr_accessor :trainee_page, :trainee_interaction

  def klass
    object.klass.decorate
  end

  def status
    KlassTrainee::STATUSES[object.status]
  end

  def updated_with_ojt_enrolled?
    return false unless trainee_interaction

    trainee_interaction.ojt_enrolled?
  end

  def ojt_enrolled_message
    'You entered placement information with OJT Enrolled status. ' \
    'Class trainee status will not reflect this change. '\
    'Go to Trainee page to update placement data.'
  end
end
