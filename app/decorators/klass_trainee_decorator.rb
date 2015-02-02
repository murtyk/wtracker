# decorator for klass trainee
class KlassTraineeDecorator < Draper::Decorator
  delegate_all

  attr_accessor :trainee_page, :updated, :update_employer_interactions
  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def klass
    object.klass.decorate
  end

  def status
    KlassTrainee::STATUSES[object.status]
  end
end
