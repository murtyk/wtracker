# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :klass_certificate do
    account nil
    klass nil
    name "MyString"
    description "MyString"
  end
end
