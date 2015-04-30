# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trainee_interaction do
    employer nil
    trainee nil
    status 1
    hire_title "MyString"
    hire_salary "MyString"
    comment "MyText"
  end
end
