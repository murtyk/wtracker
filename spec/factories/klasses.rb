# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :klass do
    name            { Faker::Lorem.sentence(word_count: 3) }
    description     { Faker::Lorem.sentence(word_count: 5) }
    training_hours { 1 }
    credits { 1 }
    start_date { Date.tomorrow }
    end_date { Date.tomorrow + 1.year }
    program_id { 1 }
    college_id { 1 }
  end
end
