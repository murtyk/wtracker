# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trainee_interaction do
    employer nil
    trainee nil
    status 1
    interview_date "2013-06-26"
    interviewer "MyString"
    hire_title "MyString"
    hire_salary "MyString"
    offer_title "MyString"
    offer_salary "MyString"
    comment "MyText"
  end
end
