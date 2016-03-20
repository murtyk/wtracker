require 'rails_helper'

describe 'Employers' do
  describe 'mapview' do
    before :each do
      signin_admin
    end
    after :each do
      signout
    end

    # it 'multiple no distance circles', js: true do
    #   VCR.use_cassette('employers_mapview') do
    #     visit '/employers/mapview'

    #     counties = find('#filters_county_ids').all('option').collect(&:text)

    #     counties.each do |county|
    #       select(county, from: 'filters_county_ids')
    #     end

    #     check('filters_show_colleges')

    #     click_button 'Find'

    #     wait_for_ajax

    #     Account.current_id = 1
    #     result = page.evaluate_script('Gmaps.map.markers.length')
    #     expected_count = Address
    #                      .where("addressable_type = 'Employer' and county is not null")
    #                      .count +
    #                      College.all.count
    #     expect(result).to eq(expected_count)
    #   end
    # end

    it 'one with distance circles', js: true do
      VCR.use_cassette('employers_mapview') do
        visit '/employers/mapview'

        fill_in 'filters_name', with: 'Trigyn'
        click_button 'Find'

        wait_for_ajax

        expect(page).to have_text '10 miles'
        expect(page).to have_text '20 miles'
      end
    end
  end
end
