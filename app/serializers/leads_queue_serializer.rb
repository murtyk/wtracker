# frozen_string_literal: true

class LeadsQueueSerializer < ActiveModel::Serializer
  attributes :id, :trainee_id, :status, :data
end
