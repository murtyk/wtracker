require 'rails_helper'
describe "email to employer" do
  describe "attach trainee document", js: true do
    before :each do
      signin_admin
      visit '/accounts/trainee_options'
      check 'Consider emailing trainee document to an employer as job applied'
      click_on 'Update'
      create_klasses(1, 1)
      create_employers(1)
      create_contacts(get_employers, 1)
    end
    after :each do
      destroy_all_created
    end

    it "considered as trainee submit - job applied" do

      visit trainee_path(get_trainees.first)

      VCR.configure do |config|
        config.allow_http_connections_when_no_cassette = true
      end

      click_link "new_trainee_file_link"
      filepath = "#{Rails.root}/spec/fixtures/RESUME.docx"
      # puts filepath
      page.attach_file "trainee_file_file", filepath
      wait_for_ajax
      fill_in 'Notes', with: 'Resume'
      click_on 'Add'
      wait_for_ajax

      visit('/emails/new')
      find_field('Subject').set 'reference101'
      fill_in 'Content', with: 'Hello, how are you?'

      fill_in 'name', with: 'Company'
      click_on 'Find'
      wait_for_ajax
      select('Client1 Client1(Company1)', from: 'select_contacts')
      click_button 'add-selected-contacts'

      select('Engineering1', from: 'select_klass_id')
      wait_for_ajax
      # check 'RESUME.docx'
      find(:css, "[value='RESUME.docx']").set(true)
      click_button 'Send'

      visit trainee_path(get_trainees.first)
      sleep 2
      expect(page).to have_text 'reference101'

    end

  end
end