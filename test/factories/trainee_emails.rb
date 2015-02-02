# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trainee_email do
    account nil
    user nil
    klass nil
    trainee_names "MyText"
    trainee_ids "MyText"
    subject "MyString"
    content "MyText"
  end
end
