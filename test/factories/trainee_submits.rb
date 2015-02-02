# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trainee_submit do
    account nil
    trainee nil
    employer nil
    title "MyString"
  end
end
