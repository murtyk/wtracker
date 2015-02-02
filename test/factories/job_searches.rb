# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :job_search do
    keywords "MyString"
    location "MyString"
    user nil
    account nil
  end
end
