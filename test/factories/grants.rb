# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :grant do
    name "MyString"
    start_date "2013-06-06"
    end_date "2013-06-06"
    status 1
    account_id 1
  end
end
