require 'rails_helper'

describe 'Report' do
  describe 'Employers' do
    before :each do
      signin_admin
    end

    it 'lists only placed trainees' do
      Account.current_id = 1
      Grant.current_id = Grant.first.id
      college = College.first
      klass = Program.first.klasses.create(name: 'A Class', college_id: college.id)
      trainees = (1..3).map do |n|
        attr = { first: "First#{n}", last: "Last#{n}", email: "email#{n}@nomail.com" }
        t = Trainee.create(attr)
        klass.klass_trainees.create(trainee_id: t.id, status: 1)
        t
      end
      company = Employer.create(name: 'Good Company 1', source: 'RSPEC')

      trainees[0].trainee_interactions.create(employer_id: company.id,
                                              status: 4,
                                              start_date: Date.tomorrow,
                                              hire_salary: '11.50',
                                              hire_title: 'Title 1234',
                                              comment: 'This employer hired')

      trainees[1].trainee_interactions.create(employer_id: company.id,
                                              status: 3,
                                              offer_date: Date.yesterday,
                                              offer_salary: '11.50',
                                              offer_title: 'Title 1234',
                                              comment: 'got an offer')

      trainees[2].trainee_interactions.create(employer_id: company.id,
                                              status: 1)

      visit_report Report::EMPLOYERS_HIRED
      select 'All', from: 'Class'
      click_on 'Find'

      expect(page).to have_text 'First1 Last1'
      expect(page).to have_text 'Title 1234'
      expect(page).to have_text '11.50'
      expect(page).to have_text 'This employer hired'

      expect(page).to_not have_text 'First2 Last2'
      expect(page).to_not have_text 'Offer'

      expect(page).to_not have_text 'First3 Last3'
    end
  end
end
