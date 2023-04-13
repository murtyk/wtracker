# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :address do |f|
    f.line1      { Faker::Address.street_address }
    f.city       { Faker::Address.city }
    f.state      { Faker::Address.state_abbr }
    f.zip        { Faker::Address.zip }
    f.longitude  { Faker::Address.longitude }
    f.latitude   { Faker::Address.latitude }
    f.county_id  { 1 }
    f.county     { 'mycounty' }
  end
end
