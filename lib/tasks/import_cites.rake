# frozen_string_literal: true

namespace :cities do
  def clean_zip(z)
    return z.to_s if z.to_s.length == 5

    part = z.to_s.split(' ').first
    ("0000#{part}")[-4..-1]
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def import_cities(file)
    csv = CSV.open(open(file), 'rb', headers: true, return_headers: true, row_sep: :auto)

    # header = csv.first

    loop do
      r = csv.shift
      break unless r

      state = State.find_by(code: r['state_id'])
      unless state
        puts "state #{r['state_id']} not found"
        next
      end

      county = state.counties.where('name ilike ?', r['county_name']).first
      unless county
        puts "county #{r['county_name']} not found for state #{state.code}"
        next
      end

      if r['zip'].empty?
        puts "invalid zip #{r}"
        next
      end

      city = county.cities.where('name ilike ?', r['city']).first
      next if city

      city_state = "#{r['city']},#{state.code}"

      city = county.cities.new(
        state_id: state.id,
        state_code: state.code,
        city_state: city_state,
        name: r['city'],
        longitude: r['lng'],
        latitude: r['lat'],
        zip: clean_zip(r['zip'])
      )

      if city.save
        print '.'
      else
        puts "error saving city: #{city.errors.first}"
      end
    end
  end

  task :import, [:file_path] => :environment do |_t, args|
    file = args['file_path']
    import_cities(file)
  end
end
