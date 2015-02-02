module ValidationsMixins
  def validate_email
    return true if email.blank?
    valid_email = true
    parts = email.split('@')
    valid_email = parts.count == 2
    if valid_email
      parts = parts[1].split('.')
      valid_email = parts.count > 1
    end
    errors.add(:email, 'invalid email address') unless valid_email
    valid_email
  end

  def validate_state_code
    return false unless state_code.size == 2
    state = State.where(code: state_code).first
    errors.add(:state, 'invalid state code') unless state
    state
  end
end
