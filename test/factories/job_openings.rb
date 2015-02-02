# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :job_opening do
    jobs_no 1
    skills "MyString"
    employer nil
    account nil
  end
end
