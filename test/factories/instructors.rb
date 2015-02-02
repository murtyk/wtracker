# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :instructor do
    name "MyString"
    comment "MyString"
    klass nil
    account nil
  end
end
