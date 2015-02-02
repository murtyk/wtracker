# decorator for employer klass interaction
class KlassInteractionDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def status
    return KlassInteraction::STATUSES[object.status] unless klass_event.cancelled?
    "<span style='color: red'>".html_safe +
    KlassInteraction::STATUSES[object.status] +
    '</span>'.html_safe
  end
end
