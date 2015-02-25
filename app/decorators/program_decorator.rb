# decorator for program
class ProgramDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def user_klasses(user)
    grant = Grant.find Grant.current_id
    return klasses if user.admin_access? || user.grants.include?(grant)
    assigned_klasses(user)
  end

  def assigned_klasses(user)
    user.navigator_klasses.where(program_id: id)
  end
end
