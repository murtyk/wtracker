# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :grant do
    name "Grant Name"
    start_date Date.yesterday
    end_date Date.today + 2.years
    status 1
  end
end
