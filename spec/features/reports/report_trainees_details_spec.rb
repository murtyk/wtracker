require 'rails_helper'

describe 'Reports' do
  describe 'Trainee' do
    before :each do
      signin_admin
    end

    it 'shows details' do
      Account.current_id = 1
      Grant.current_id = Grant.first.id
      college = College.first
      klass = Program.first.klasses.create(name: 'A Class', college_id: college.id)
      trainees = (1..6).map do |n|
        attr = { first: "First#{n}", last: "Last#{n}", email: "email#{n}@nomail.com" }
        t = Trainee.create(attr)
        klass.klass_trainees.create(trainee_id: t.id, status: n)
        t
      end

      address_attr = { line1: '10 Rembrandt', city: 'East Windsor', state: 'NJ',
                       zip: '08520', latitude: 33.33, longitude: -73.33 }

      trainee = trainees.first

      trainee.update(home_address_attributes: address_attr)

      attrs = { trainee_id: 'AZ11110000', dob: '07 June 1992', gender: 1,
                land_no: '7778882222', veteran: true }
      trainee.update(attrs)

      ed = Education.where(name: 'GED').first
      tact3_attrs = { education_level: ed.id, recent_employer: 'Some Company',
                      job_title: 'A title', certifications: 'PMP CBA' }

      trainee.update(tact_three_attributes: tact3_attrs)

      visit_report Report::TRAINEES_DETAILS

      select klass.name,       from: 'Class'
      click_on 'Find'

      (1..6).each do |seq|
        expect(page).to have_text "First#{seq} Last#{seq}"
        expect(page).to have_text KlassTrainee::STATUSES[seq]
      end

      expect(page).to have_text 'AZ11110000'
      expect(page).to have_text '10 Rembrandt'
      expect(page).to have_text 'East Windsor'
      expect(page).to have_text 'NJ'
      expect(page).to have_text '08520'

      expect(page).to have_text '(777) 888-2222'
      expect(page).to have_text '06/07/1992'
      expect(page).to have_text 'GED'

      expect(page).to have_text 'Some Company'
      expect(page).to have_text 'A title'
      expect(page).to have_text 'PMP CBA'
    end
  end
end
