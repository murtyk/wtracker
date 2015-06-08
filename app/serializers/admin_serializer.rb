class AdminSerializer < ActiveModel::Serializer
  attributes :email, :auth_token
end
