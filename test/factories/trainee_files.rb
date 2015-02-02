# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trainee_file do
    trainee nil
    file "MyString"
    notes "MyString"
    uploaded_by 1
  end
end
