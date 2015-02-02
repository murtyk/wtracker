# decorator for grant
class GrantDecorator < Draper::Decorator
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
    Grant::STATUSES[object.status]
  end

  def amount
    number_to_currency(object.amount, precision: 0)
  end
end
