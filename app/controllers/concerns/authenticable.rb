# frozen_string_literal: true

module Authenticable
  # Devise methods overwrites
  def current_admin
    @current_admin ||= Admin.find_by(auth_token: request.headers['Authorization'])
  end

  def authenticate_with_token!
    unless admin_signed_in?
      render json: { errors: 'Not authenticated' },
             status: :unauthorized
    end
  end

  def admin_signed_in?
    current_admin.present?
  end
end
