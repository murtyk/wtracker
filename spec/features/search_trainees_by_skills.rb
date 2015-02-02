require 'rails_helper'

describe "Trainees" do
  describe "search by skills" do
    before(:each) do
      signin_autolead_director
    end
    after :each do
      signout
    end
    it "lets you find trainees with matching skills" do
      account = Account.where(subdomain: 'njit').first
      Account.current_id = account.id
      Grant.current_id   = account.grants.first.id
      klass = Klass.first
      trainee1 = klass.trainees.create(first: 'first1', last: 'last1', email: 'first1@mail.com')
      trainee2 = klass.trainees.create(first: 'first2', last: 'last2', email: 'first2@mail.com')
      trainee1.create_job_search_profile(skills: 'java sdlc ajax',
                                         location: 'city,st',
                                         distance: 5,
                                         key: 'key1')
      trainee2.create_job_search_profile(skills: 'ruby jquery sdlc',
                                         location: 'city,st',
                                         distance: 5,
                                         key: 'key2')
      visit '/trainees/search_by_skills'

      fill_in 'filters_skills', with: 'sdlc'
      click_on 'Find'
      expect(page).to have_text('first1 last1')
      expect(page).to have_text('first2 last2')

      fill_in 'filters_skills', with: 'java pmp'
      click_on 'Find'
      expect(page).to have_text('first1 last1')
      expect(page).to_not have_text('first2 last2')

    end
  end
end
