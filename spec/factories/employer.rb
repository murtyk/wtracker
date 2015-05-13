require 'faker'
FactoryGirl.define do
  factory :employer do |f|
    f.name { Faker::Company.name }
  end
end
