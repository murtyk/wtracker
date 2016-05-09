FactoryGirl.define do
  factory :leads_queue do
    trainee_id 1
    status 1
    jsp_id 1
    skills 'Java, Ajax, Ruby'
    distance 10
    location 'Edison,NJ'
    trainee_ip '33.32.43.22'
    last_date_posted Date.today - 7.days
    email_from 'jobleads@wtracker.com'
    email_reply_to 'noone@nomail.net'
    email_to 'trainee@nomail.net'
    email_subject 'Hello'
    email_body 'Job Leads For You'
  end
end
