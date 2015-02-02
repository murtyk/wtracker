# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :college do |f|
    f.name { Faker::Company.name }
  end
end
