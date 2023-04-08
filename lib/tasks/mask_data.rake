# frozen_string_literal: true

namespace :admin do
  desc 'for a given account by subdomain, mask all the SSNs and emails'
  task :mask_data, [:subdomain] => :environment do |_t, args|
    account = Account.find_by(subdomain: args[:subdomain])
    raise "account not found for #{subdomain}" unless account

    Account.current_id = account.id
    grants = Account.grants

    grants.each do |grant|
      puts "masking for grant: #{grant.name}"
      Grant.current_id = grant.id

      puts "# of Trainees: #{Trainee.count}"
      Trainee.includes(:applicant).each do |trainee|
        email = random_email(trainee)
        trainee.update(email: email, trainee_id: random_id)

        applicant = trainee.applicant
        applicant&.update(email: email)

        print '.'
      end

      puts '-------'
    end
  end

  def random_id
    (0..9).to_a.shuffle.map(&:to_s).join('')
  end

  def random_email(trainee)
    email = trainee.email
    parts = email.split('@')
    name = parts[0] || trainee.name.split(' ').join('_') || random_name
    "#{name}@#{random_domain}"
  end

  def random_domain
    "#{random_string(5)}.#{%w[net biz blah].sample}"
  end

  def random_name
    [random_string, random_string].join('_')
  end

  def random_string(length = 4)
    ('a'..'z').to_a.shuffle[1..length].join('')
  end
end
