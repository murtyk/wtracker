# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :klass_schedule do
    klass nil
    scheduled false
    dayoftheweek 1
    start_time_hr 1
    start_time_min 1
    start_ampm "MyString"
    end_time_hr 1
    end_time_min 1
    end_ampm "MyString"
  end
end
