# frozen_string_literal: true

require 'faker'
FactoryBot.define do
  factory :applicant do
    trait :acceptable do
      current_employment_status { 'Employed Part Time' }
    end

    trait :not_acceptable do
      current_employment_status { 'Employed Full Time' }
    end

    first_name    { Faker::Name.first_name }
    last_name     { Faker::Name.last_name }
    unique_id     { Faker::Number.number(9) }
    dob           { 40.years.ago.to_date.to_s }
    email         { Faker::Internet.email }
    email_confirmation { email }

    address_line1 { '100 Metroplex Dr.' }
    address_city  { 'Edison' }
    address_zip   { '08817' }

    county_id     do
      County.find_by(state_id: State.find_by(code: 'NJ'), name: 'Middlesex').id
    end

    mobile_phone_no { Faker::PhoneNumber.cell_phone }
    sector_id       { Sector.all.sample.id }
    veteran         { [true, false].sample }
    legal_status    { [1, 2].sample }
    gender          { [1, 2].sample }
    race_id         { Race.all.sample.id }

    last_employed_on    { (Date.today - 6.months).to_s }
    last_employer_name  { Faker::Company.name }
    last_employer_line1 { Faker::Address.street_address }
    last_employer_city  { Faker::Address.city }
    last_employer_state { 'NJ' }
    last_employer_zip   { Faker::Address.zip }

    last_employer_manager_name     { Faker::Name.name }
    last_employer_manager_phone_no { Faker::PhoneNumber.phone_number }

    last_wages { '100K' }
    last_job_title { Faker::Job.title }
    salary_expected { '75-85K' }

    education_level      { Education.all.sample.id }
    unemployment_proof   { UnemploymentProof.unscoped.all.sample.name }
    special_service_ids  { [SpecialService.unscoped.all.sample.id] }
    transportation       { [true, false].sample }
    computer_access      { [true, false].sample }
    source               { ApplicantSource.unscoped.all.sample.source }

    resume  { Faker::Lorem.paragraph(sentence_count: 5) }
    skills  { Faker::Lorem.paragraph(sentence_count: 2) }
    humanizer_answer { '4' }
    signature { '1' }

    factory :acceptable_applicant, traits: [:acceptable]
    factory :not_acceptable_applicant, traits: [:not_acceptable]
  end
end
