require 'rails_helper'

def create_auto_leads_profiles
  @account = Account.find_by(subdomain: 'njit')
  Account.current_id = @account.id

  @grant = Grant.first
  Grant.current_id = @grant.id

  @trainees = []

  trainee = Trainee.create(first: 'First1', last: 'Last1', email: 'first1@nomail.net')

  jsp_attrs = { account_id: @account.id,
                key: '12345678',
                skills: 'java, ajax',
                location: 'Edison, NJ',
                distance: 20
              }
  trainee.create_job_search_profile(jsp_attrs)

  @trainees << trainee

  trainee = Trainee.create(first: 'First2', last: 'Last2', email: 'first2@nomail.net')

  jsp_attrs = { account_id: @account.id,
                key: '12345678',
                skills: 'Accounting',
                location: 'Edison, NJ',
                distance: 20,
                opted_out: true
              }
  trainee.create_job_search_profile(jsp_attrs)
  @trainees << trainee

  @trainees << Trainee.create(first: 'First3', last: 'Last3', email: 'first3@nomail.net')
end

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
      create_auto_leads_profiles

      signin_autolead_director

      expect(page).to have_text 'Job Leads Metrics'

      AutoLeadsMetrics::METHOD_MAP.keys.each do |status|
        href = "/dashboards?auto_leads_metrics=true&status=#{status}"
        expect(page).to have_selector("a[href='#{href}']")
      end

      click_on 'No. of students updated job search profile'

      expect(page).to have_text @trainees[0].name
      expect(page).to have_text @trainees[0].skills
      expect(page).to have_text @trainees[1].name
      expect(page).to have_text @trainees[1].skills

      click_on 'Dashboard'
      click_on 'No. of students opted out'
      expect(page).to have_text @trainees[1].name
      expect(page).to_not have_text @trainees[0].name

      click_on 'Dashboard'
      click_on 'No. of students NOT updated job search profile'

      expect(page).to have_text @trainees[2].name

      click_on 'Dashboard'
      click_on 'Skill Metrics'
      expect(page).to have_text 'java'
    end
    it 'shows trainees by placement and funding source for applicants grant' do
      signin_applicants_director
      expect(page).to have_text '# Trainees'
      expect(page).to have_text 'Placed'
      expect(page).to have_text 'OJT Enrolled'

      href = '/trainees/advanced_search?q%5Bapplicant_navigator_id_eq%5D=&q%5Bfunding_source_id_eq%5D='
      expect(page).to have_selector("a[href='#{href}']")
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
