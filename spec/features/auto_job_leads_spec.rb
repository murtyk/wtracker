require 'rails_helper'

# test data is set up for one trainee in njit account
describe 'auto job leads' do
  describe 'dashboard' do
    it 'shows metrics' do
      signin_autolead_director
      click_on 'Dashboard'
      expect(page).to have_text('Job Leads Metrics')
      signout
    end
  end

  describe 'update status' do
    it 'updates profile' do
      VCR.use_cassette('auto_job_leads') do

        # we have a trainee without a job search profile. it should send an email to update profile
        expect(JobSearchProfile.count).to eq(0)

        AutoJobLeads.new.delay.perform
        Delayed::Worker.new.work_off

        expect(JobSearchProfile.count).to eq(1)

        #now trainee updates profile and it should generate leads
        profile = JobSearchProfile.last
        id   = profile.id
        key  = profile.key

        switch_to_auto_leads_domain
        visit "/profiles/#{id}/edit?key=#{key}"
        expect(page).to have_text 'Please enter your preferences for job leads'

        fill_in 'Skills', with: 'SDLC, Java, Project Lead'
        fill_in 'Location', with: 'Edison,NJ'
        fill_in 'Distance', with: 25

        click_on 'Update'

        expect(page).to have_text 'You will begin receiving e-mails with job postings ' \
                                  'that match your skills and geographic preference.'
        AutoJobLeads.new.perform
        visit "/profiles/#{id}?key=#{key}"
        expect(page).to have_text 'Software Development Consultant (104634)'
        expect(page).to have_text 'Status:Not Viewed'
      end
    end
    # it "can send profile reminder" do
    #   pending 'need to develop this spec soon'
    #   fail
    # end
  end

  describe 'opt out' do
    before :each do
      # generate profile
      AutoJobLeads.new.perform
      profile = JobSearchProfile.first
      @id   = profile.id
      @key  = profile.key
    end
    it 'trainee opts out and director can view' do
      switch_to_auto_leads_domain
      visit "/profiles/#{@id}/edit?key=#{@key}&opt_out=true"

      select 'Moved out of the area', from: 'Status'
      click_on 'Update'

      profile = JobSearchProfile.first

      expect(page).to have_text(profile.opted_out_confirmation_message)

      signin_autolead_director
      click_on 'Dashboard'
      click_on 'No. of students opted out'
      expect(page).to have_text('first last')
    end
  end
end
