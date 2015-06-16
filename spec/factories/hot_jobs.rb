require 'faker'
FactoryGirl.define do
  factory :hot_job do
    account_id 1
    user_id 1
    employer_id 1
    date_posted Date.today
    closing_date Date.today + 30.days
    title Faker::Name.title
    description Faker::Lorem.paragraph
    salary 22
    location Faker::Address.city
  end
end
