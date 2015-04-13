require 'rails_helper'

describe 'Trainees' do
  describe 'Dropeed or Not Placed Report' do
    before :each do
      signin_admin
    end

    it 'shows the trainees with completed and dropped status' do
      Account.current_id = 1
      Grant.current_id = Grant.first.id
      college = College.first
      klass = Program.first.klasses.create(name: 'A Class', college_id: college.id)
      (1..5).each do |n|
        attr = { first: "First#{n}", last: "Last#{n}", email: "email#{n}@nomail.com" }
        t = Trainee.create(attr)
        klass.klass_trainees.create(trainee_id: t.id, status: n)
      end

      # STATUSES = { 1 => 'Enrolled', 2 => 'Completed',
      #              3 => 'Dropped', 4 => 'Placed', 5 => 'Continuing Education' }

      visit_report Report::TRAINEES_NOT_PLACED
      select 'All', from: 'Class'
      click_on 'Find'

      expect(page).to_not have_text 'First1 Last1' # enrolled

      (2..3).each do |seq|
        expect(page).to have_text "First#{seq} Last#{seq}" # completed or dropped
        expect(page).to have_text KlassTrainee::STATUSES[seq]
      end

      (4..5).each do |seq|
        # hired or conitnuing education
        expect(page).to_not have_text "First#{seq} Last#{seq}"
      end
    end
  end
end
