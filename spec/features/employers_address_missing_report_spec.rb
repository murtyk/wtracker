require 'rails_helper'

describe "Report" do
  describe 'Employers' do

    before :each do
      signin_admin
    end

    it 'missing address' do

      Account.current_id = 1
      employers = (1..3).map do |n|
        Employer.create(name: "Good Company #{n}", source: 'RSPEC')
      end

      attrs = { line1: 'Street Address', city: 'Edison', state: 'NJ', zip: '08520',
                longitude: 33.23, latitude: -34.55 }

      employers.first.update(address_attributes: attrs)

      visit_report 'employers_no_address'

      expect(page).to have_text "Good Company 2"
      expect(page).to have_text "Good Company 3"

      expect(page).to_not have_text "Good Company 1"
    end

  end

end