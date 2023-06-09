# frozen_string_literal: true

require 'faker'
FactoryBot.define do
  factory :trainee do |f|
    f.first { Faker::Name.first_name }
    f.last { Faker::Name.last_name }
    f.email { Faker::Internet.email }
  end
end
