require 'rails_helper'

describe 'Dashboard' do
  describe 'director user' do
    after :each do
      signout
    end
    it 'shows programs and classes for standard grant' do
      signin_director
      Account.current_id = 1
      Grant.current_id = 1
      Klass.all.each do |klass|
        expect(page).to have_text klass.name
      end
    end
    it 'shows job leads metrics for autoleads grant' do
      signin_autolead_director
      expect(page).to have_text 'Job Leads Metrics'
    end
    it 'shows trainees by placement and funding source for applicants grant' do
      signin_applicants_director
      expect(page).to have_text '# Trainees'
      expect(page).to have_text 'Placed'
      expect(page).to have_text 'OJT Enrolled'
    end
  end

  describe 'admin user' do
    after :each do
      signout
    end
    it 'shows programs and classes for standard grant' do
      signin_admin
      Account.current_id = 1
      Grant.current_id = 1
      Klass.all.each do |klass|
        expect(page).to have_text klass.name
      end
    end
  end
end
