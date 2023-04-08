# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :college do |f|
    f.name { Faker::Company.name }
  end
end
