# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :klass do
    name "MyString"
    description "MyString"
    training_hours 1
    credits 1
    start_date "2013-06-10"
    end_date "2013-06-10"
    program ""
    account ""
  end
end
