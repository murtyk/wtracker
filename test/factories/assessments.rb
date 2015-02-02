# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :assessment do
    account nil
    name "MyString"
    administered_by 1
  end
end
