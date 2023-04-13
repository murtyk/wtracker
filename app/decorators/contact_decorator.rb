# frozen_string_literal: true

# decorator for Contact
class ContactDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end
  def title
    return nil if object.title.blank?

    '<br>'.html_safe + object.title
  end

  def land_no
    return nil if object.land_no.blank?

    "#{'<br>'.html_safe}#{h.format_phone_no(object.land_no, ext)}(w)"
  end

  def mobile_no
    return nil if object.mobile_no.blank?

    "#{'<br>'.html_safe}#{h.format_phone_no(object.mobile_no)}(m)"
  end

  def email
    return nil if object.email.blank?

    '<br>'.html_safe + object.email
  end

  def details
    name.html_safe + title.to_s + land_no.to_s + mobile_no.to_s + email.to_s
  end
end
