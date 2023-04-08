# frozen_string_literal: true

class AdminSerializer < ActiveModel::Serializer
  attributes :email, :auth_token
end
