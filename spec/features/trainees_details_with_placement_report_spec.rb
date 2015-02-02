require 'rails_helper'

describe "Reports" do
  describe 'Trainee' do
    before :each do
      signin_admin
    end

    it 'shows details' do

      Account.current_id = 1
      Grant.current_id = Grant.first.id
      college = College.first
      klass = Program.first.klasses.create(name: 'A Class', college_id: college.id)
      trainees = (1..2).map do |n|
        attr = { first: "First#{n}", last: "Last#{n}", email: "email#{n}@nomail.com"}
        t = Trainee.create(attr)
        klass.klass_trainees.create(trainee_id: t.id, status: n)
        t
      end

      address_attr = { line1: '10 Rembrandt', city: 'East Windsor', state: 'NJ',
                       zip: '08520', latitude: 33.33, longitude: -73.33 }

      trainee = trainees.first

      trainee.update(home_address_attributes: address_attr)

      attrs = { trainee_id: 'AZ11110000', dob: '07 June 1992', gender: 1,
                land_no: '7778882222', veteran: true}
      trainee.update(attrs)

      ed = Education.where(name: 'GED').first
      tact3_attrs = { education_level: ed.id, recent_employer: 'Some Company',
                      job_title: 'A title', certifications: 'PMP CBA'}

      trainee.update(tact_three_attributes: tact3_attrs)


      trainee = trainees.last
      employer = Employer.first

      attrs = { employer_id: employer.id, status: 4, start_date: '20 August 2016',
                hire_salary: '$20/hr', hire_title: 'Truck Driver' }
      trainee.trainee_interactions.create(attrs)
      trainee.klass_trainees.first.update(status: 4)

      visit('/reports/new?report=trainees_details_with_placement')
      select 'All', from: 'filters_klass_ids'
      click_on 'Find'

      expect(page).to have_text "First1 Last1"

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

      expect(page).to have_text employer.name

    end
  end

end
