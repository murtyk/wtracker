# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryBot.define do
  factory :user do |f|
    f.first { Faker::Name.first_name }
    f.last  { Faker::Name.last_name }
    f.email { Faker::Internet.email }
    f.location { Faker::Address.city }

    f.status   { 1 }
    f.role     { 3 }  # default to navigator
    f.password { 'password' }
    f.password_confirmation { 'password' }
  end
end
