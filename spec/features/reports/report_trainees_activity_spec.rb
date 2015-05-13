require 'rails_helper'

describe 'Reports' do
  describe 'Trainees' do
    before :each do
      signin_admin
    end

    it 'activities report' do
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

      visit_report Report::TRAINEES_ACTIVITY
      select 'A Class', from: 'Class'
      click_on 'Find'

      (1..3).each do |n|
        expect(page).to have_content "First#{n} Last#{n}"
      end

      expect(page).to_not have_content 'This is Notes'

      Account.current_id = 1
      Grant.current_id = Grant.first.id
      company = Employer.create(name: 'Company1')

      trainee = trainees.first
      trainee.trainee_notes.create(notes: 'This is Notes.')
      trainee.trainee_interactions.create(employer_id: company.id,
                                          status: 4,
                                          comment: 'This employer hired')

      visit_report Report::TRAINEES_ACTIVITY
      select 'A Class', from: 'Class'
      fill_in 'To', with: Date.tomorrow

      click_on 'Find'

      expect(page).to have_content 'This is Notes'
      expect(page).to have_content 'Company1'
      expect(page).to have_content 'No OJT'

      # change the end_date to yesterday
      fill_in 'To', with: Date.yesterday
      click_on 'Find'
      expect(page).to_not have_content 'This is Notes'
      expect(page).to_not have_content 'Company1'
      expect(page).to_not have_content 'No OJT'

      visit_report Report::TRAINEES_ACTIVITY
      select 'A Class', from: 'Class'
      click_on 'Find'

      expect(page).to have_content 'First1 Last1'

      Account.current_id = 1
      Grant.current_id = Grant.first.id
      trainee = trainees.last
      klass_trainee = trainee.klass_trainees.first
      klass_trainee.update(status: 2)

      select 'Completed', from: 'Status'
      fill_in 'To', with: Date.tomorrow
      click_on 'Find'
      expect(page).to_not have_content 'First1 Last1'
      expect(page).to_not have_content 'First2 Last2'
      expect(page).to have_content 'First3 Last3'
    end
  end
end
