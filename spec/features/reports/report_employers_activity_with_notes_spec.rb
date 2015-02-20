require 'rails_helper'

describe "Reports" do
  describe 'Employer' do
    before :each do
      signin_admin
    end

    it 'activities with notes report' do
      Account.current_id = 1
      notes = []
      employers = (1..2).map do |n|
        note = n.to_s + '. This is a' + ' note' * 25 +
               '. It should be long and display create date'
        employer = Employer.create(name: "Good Company #{n}", source: 'RSPEC')
        employer.employer_notes.create(note: note)
        notes << note
        employer
      end

      visit_report Report::EMPLOYERS_ACTIVITIES_WITH_NOTES
      fill_in 'To', with: Date.current
      click_on 'Find'

      notes.each do |note|
        expect(page).to have_content note
      end

    end
  end
end
