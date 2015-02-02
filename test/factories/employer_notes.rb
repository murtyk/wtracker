# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :employer_note do
    employer nil
    note "MyString"
  end
end
