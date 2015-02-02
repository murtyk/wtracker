# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :klass_interaction do
    employer nil
    klass_event nil
    status "MyString"
  end
end
