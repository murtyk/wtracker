# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :auto_shared_job do
    account ""
    trainee nil
    title "MyString"
    company "MyString"
    date_posted "MyString"
    location "MyString"
    excerpt "MyText"
    url "MyString"
    status 1
    feedback "MyText"
    key "MyString"
  end
end
