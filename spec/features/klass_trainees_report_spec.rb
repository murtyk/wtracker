require 'rails_helper'

describe "Reports" do
  describe 'Trainees' do
    before :each do
      signin_admin
    end

    after :each do
      signout
    end

    it 'status report' do

      Account.current_id = 1
      Grant.current_id = Grant.first.id
      college = College.first
      klass = Program.first.klasses.create(name: 'A Class', college_id: college.id)
      trainees = (1..3).map do |n|
        attr = { first: "First#{n}", last: "Last#{n}", email: "email#{n}@nomail.com"}
        t = Trainee.create(attr)
        klass.klass_trainees.create(trainee_id: t.id, status: 1)
        t
      end

      visit "/reports/new?report=#{Report::CLASS_TRAINEES}"
      select klass.name, from: 'filters_klass_id'
      click_on 'Find'

      (1..3).each do |n|
        expect(page).to have_text "First#{n} Last#{n}"
      end

    end
  end
end
