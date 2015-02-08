# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :city do |f|
    f.name         { Faker::Address.city }
    f.zip          { Faker::Address.zip }
    f.longitude    { Faker::Address.longitude }
    f.latitude     { Faker::Address.latitude }
    f.state_id     { 1 }
    f.county_id    { 1 }
  end
end

