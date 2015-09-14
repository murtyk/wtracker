# user decorator
# mainly used in index view
class UserDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def role
    User::ROLES[object.role]
  end

  def role_description
    return role unless navigator? && acts_as_admin?
    role + ' (Acts as Admin)'
  end

  def status
    User::STATUSES[object.status]
  end

  def online_status
    object.online? ? '<i class="icon-ok icon-2X"></i>'.html_safe : ''
  end

  def land_no
    h.format_phone_no(object.land_no)
  end

  def mobile_no
    h.format_phone_no(object.mobile_no)
  end

  def assigned_to_header
    return nil unless object.navigator? || object.instructor?
    return '<strong>Assigned as Navigator to:</strong>'.html_safe if object.navigator?
    '<strong>Assigned as Instructor to:</strong>'.html_safe
  end

  def assigned_klasses
    return []  unless object.navigator? || object.instructor?
    return object.navigator_klasses if object.navigator?
    object.instructor_klasses
  end

  def assigned_county_names
    counties.map(&:name).join('; ')
  end

  def employer_sources_list
    employer_sources.map do |s|
      if default_employer_source_id.to_i == s.id
        "<li><b>#{s.name}</b></li>"
      else
        "<li>#{s.name}</li>"
      end
    end.join.html_safe
  end
end
