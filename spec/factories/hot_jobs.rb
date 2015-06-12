FactoryGirl.define do
  factory :hot_job do
    account_id 1
    user_id 1
    employer_id 1
    date_posted Date.today
    closing_date Date.today + 30.days
    title "MyString"
    description "MyString"
    salary "MyString"
    location "MyString"
  end
end
