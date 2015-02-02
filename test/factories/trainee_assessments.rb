# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trainee_assessment do
    account nil
    trainee nil
    assessment nil
    score "MyString"
    pass false
  end
end
