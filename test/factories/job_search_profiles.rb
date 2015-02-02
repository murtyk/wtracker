# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :job_search_profile do
    account nil
    trainee nil
    skills "MyText"
    location "MyString"
    distance 1
    key "MyString"
  end
end
