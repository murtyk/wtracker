require 'faker'
namespace :data do
  task :trainees, [:state_code] => :environment do |_t, args|
    state_code = args['state_code']
    state = State.find_by(code: state_code)

    file_path = "./tmp/trainees_#{Time.now.strftime('%Y%m%d_%H%M%S')}"

    header = %w(first_name last_name middle_name dob gender veteran land_no mobile_no email trainee_id education ethnicity home_address:line1 home_address:city home_address:state home_address:zip mail_address:line1 mail_address:city mail_address:state mail_address:zip recent_employer job_title years certifications current_employment_status last_employed_on last_wages legal_status funding_source registration_date)

    csv_data = CSV.generate do |csv|
      csv << header
      state.cities.sample(10).each do |city|
        rows = generate_city_trainees(city, 5)
        rows.each { |r| csv << r }
        print '.'
      end
    end

    File.open(file_path, 'wb') do |file|
      file.write(csv_data)
    end

    puts file_path
  end

  def generate_city_trainees(city, n)
    addresses = generate_city_addresses(city, n)

    addresses.map do |a|
      [
        Faker::Name.first_name, Faker::Name.last_name, '', data_dob,
        %w(M F).sample, data_veteran, a[:phone], a[:phone], Faker::Internet.email,
        Faker::Number.number(9), data_education, data_ethnicity,
        a[:line1], a[:city], a[:state], a[:zip],
        a[:line1], a[:city], a[:state], a[:zip],
        '', '', '', '',
        '', '', '', '',
        data_fs, data_registration_date
      ]
    end
  end

  def data_dob
    rand(35..45).years.ago.to_date.to_s
  end

  def data_education
    Education.all.sample.name
  end

  def data_ethnicity
    Race.all.sample.name
  end

  def data_veteran
    rand(0..9) > 7 ? 'x' : ''
  end

  def data_registration_date
    rand(1.year.ago..2.months.ago).to_date.strftime('%m/%d/%y')
  end

  def data_fs
    ['One Stop', 'HPOG', 'NEG', 'RTW', 'USAID'].sample
  end

  def generate_city_addresses(city, n)
    refs = GoogleApi.generate_addresses('lodging', city.latitude, city.longitude, n)

    addresses = []
    refs.each do |ref|
      fa = ref['formatted_address']
      next unless fa.include?(city.state_code)

      parts = fa.split(',')
      # expect "2700 Hercules Rd, Annapolis Junction, MD 20701, United
      next unless parts.count == 4

      next if ref['formatted_phone_number'].nil?

      phone = ref['formatted_phone_number'].split('').select { |c| c >= '0' && c <= '9' }.join('')

      addresses << {
        line1: parts[0],
        city: parts[1],
        state: city.state_code,
        zip: parts[2].split(' ')[-1],
        longitude: ref['location']['lng'],
        latitude: ref['location']['lat'],
        phone: phone
      }
    end

    addresses
  end
end
