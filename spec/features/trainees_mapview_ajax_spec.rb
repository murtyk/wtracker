require 'rails_helper'

describe 'Trainees' do
  describe 'mapview' do
    before :each do
      signin_admin
    end

    it 'multiple no distance circles', js: true do
      VCR.use_cassette('trainees_mapview') do
        visit '/trainees/mapview'

        select 'CNC 101', from: 'filters_klass_id'

        click_button 'Find'

        wait_for_ajax

        Account.current_id = 1
        Grant.current_id = 1
        klass = Klass.where(name: 'CNC 101').first
        address_count = 0
        klass.trainees.each { |t| address_count += 1 if t.home_address }

        result = 0
        10.times do
          result = page.evaluate_script('Gmaps.map.markers.length')
          break if result > 0
          sleep 0.5
        end
        expect(result).to eq address_count
      end
    end

    it 'one with distance circles', js: true do
      VCR.use_cassette('employers_mapview') do
        visit '/trainees/mapview'

        select 'CNC 101', from: 'filters_klass_id'
        wait_for_ajax

        Account.current_id = 1
        Grant.current_id = 1
        klass = Klass.where(name: 'CNC 101').first

        trainee = klass.trainees.first

        select trainee.name, from: 'filters_trainee_id'

        click_button 'Find'
        wait_for_ajax

        expect(page).to have_text '10 miles'
        expect(page).to have_text '20 miles'
      end
    end
  end
end
