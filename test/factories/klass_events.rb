# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :klass_event do
    account nil
    klass nil
    name "MyString"
    event_date "2013-06-15"
  end
end
