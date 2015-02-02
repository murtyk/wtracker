# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :program do
    name "MyString"
    description "MyString"
    grant nil
    account nil
  end
end
