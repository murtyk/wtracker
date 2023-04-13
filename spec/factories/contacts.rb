# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :contact do |f|
    f.first     { Faker::Name.first_name }
    f.last      { Faker::Name.last_name }
    f.title     { Faker::Job.title }
    f.land_no   { Faker::PhoneNumber.phone_number }
    f.mobile_no { Faker::PhoneNumber.phone_number }
    f.email     { Faker::Internet.email }
  end
end
