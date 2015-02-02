require 'rails_helper'

describe "Trainee" do
  describe 'ajax in show' do

    before :each do
      signin_admin
      create_trainees(1)
    end

    after :each do
    	destroy_all_created
    end

    it 'allows file attachments', js: true do
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

      expect(page).to have_text 'Resume'

      click_link "new_trainee_file_link"
      filepath = "#{Rails.root}/spec/fixtures/COVER LETTER.pdf"
      # puts filepath
      page.attach_file "trainee_file_file", filepath
      wait_for_ajax
      fill_in 'Notes', with: 'Cover Letter'
      click_on 'Add'
      wait_for_ajax

      expect(page).to have_text 'Cover Letter'
    end

    it 'opens file attachment', js: true do
      VCR.configure do |config|
        config.allow_http_connections_when_no_cassette = true
      end

      click_link "new_trainee_file_link"
      filepath = "#{Rails.root}/spec/fixtures/COVER LETTER.pdf"
      # puts filepath
      page.attach_file "trainee_file_file", filepath
      wait_for_ajax
      fill_in 'Notes', with: 'Cover Letter'
      click_on 'Add'
      wait_for_ajax

      expect(page).to have_text 'Cover Letter'

      click_on 'COVER LETTER.pdf'

      new_window=page.driver.browser.window_handles.last
      page.within_window new_window do
        expect(page).to have_text "MY COVER LETTER REALLY COVERS ME"
      end
    end


    it 'deletes file attachments', js: true do
      VCR.configure do |config|
        config.allow_http_connections_when_no_cassette = true
      end

      click_link "new_trainee_file_link"
      filepath = "#{Rails.root}/spec/fixtures/COVER LETTER.pdf"
      # puts filepath
      page.attach_file "trainee_file_file", filepath
      wait_for_ajax
      fill_in 'Notes', with: 'Cover Letter'
      click_on 'Add'
      wait_for_ajax

      expect(page).to have_text 'Cover Letter'

      delete_btn_id = first(:xpath, "//*[contains(@id, 'destroy_trainee_file')]")[:id]
      click_on delete_btn_id

      page.driver.browser.switch_to.alert.accept
      wait_for_ajax
      expect(page).to_not have_text 'Cover Letter'
    end
  end
end