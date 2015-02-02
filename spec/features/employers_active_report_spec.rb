require 'rails_helper'

describe "Report" do
  describe 'Employers' do

    before :each do
      signin_admin
    end

    it 'active - hired or class event participant' do

      Account.current_id = 1
      Grant.current_id = Grant.first.id
      college = College.first
      klass1 = Program.first.klasses.create(name: 'A Class', college_id: college.id)
      klass2 = Program.first.klasses.create(name: 'Another Class', college_id: college.id)
      klasses = [klass1, klass2]
      trainees = (1..2).map do |n|
        attr = { first: "First#{n}", last: "Last#{n}", email: "email#{n}@nomail.com"}
        t = Trainee.create(attr)
        klasses[n-1].klass_trainees.create(trainee_id: t.id, status: 1)
        t
      end
      company1 = Employer.create(name: 'Company 1', source: 'RSPEC')
      company2 = Employer.create(name: 'Company 2', source: 'RSPEC')

      trainee = trainees.first
      trainee.trainee_interactions.create(employer_id: company1.id,
                                          status: 4,
                                          start_date: Date.tomorrow,
                                          hire_salary: '11.50',
                                          hire_title: 'Title 1234',
                                          comment: 'This employer hired')


      visit '/reports/new?report=active_employers'
      select 'All', from: 'filters_klass_ids'
      click_on 'Find'

      expect(page).to have_text 'Company 1'
      expect(page).to have_text 'A Class'
      expect(page).to have_text 'First1 Last1'

      expect(page).to_not have_text 'Company 2'

      Account.current_id = 1
      Grant.current_id = Grant.first.id
      klass_event = klass2.klass_events.first
      klass_event.klass_interactions.create(employer_id: company2.id, status: 1)

      visit '/reports/new?report=active_employers'
      select 'All', from: 'filters_klass_ids'

      click_on 'Find'

      expect(page).to have_text 'Company 1'
      expect(page).to have_text 'A Class'
      expect(page).to have_text 'First1 Last1'

      expect(page).to have_text 'Company 2'
      expect(page).to have_text 'Another Class'

      select 'A Class', from: 'filters_klass_ids'
      unselect 'Another Class', from: 'filters_klass_ids'
      click_on 'Find'

      expect(page).to have_text 'Company 1'
      expect(page).to have_text 'A Class'
      expect(page).to have_text 'First1 Last1'

      expect(page).to_not have_text 'Company 2'

    end
  end
end