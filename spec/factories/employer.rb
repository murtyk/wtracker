# frozen_string_literal: true

require 'faker'
FactoryBot.define do
  factory :employer do |f|
    f.name { Faker::Company.name }
  end
end
