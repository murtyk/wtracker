# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shared_job_status do
    account nil
    trainee nil
    shared_job nil
    status 1
    feedback "MyString"
    key "MyString"
  end
end
