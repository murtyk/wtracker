require 'rails_helper'

def resume
  "#{Rails.root}/spec/fixtures/RESUME.docx"
end

def cover_letter
  "#{Rails.root}/spec/fixtures/COVER LETTER.pdf"
end
describe 'EmployerFile', js: true do
  describe 'can attach multiple files' do
    before :each do
      signin_admin
      create_employers(1)

      @filepath = resume
      allow(Amazon).to receive(:store_file).and_return('thisisawsfilename')
      allow(Amazon).to receive(:file_url).and_return(@filepath)
      allow(Amazon).to receive(:original_file_name).and_return('RESUME.docx')
      allow(Amazon).to receive(:delete_file).and_return(nil)
    end

    after :each do
      destroy_all_created
    end

    it 'allows attachments' do
      click_link 'new_employer_file_link'

      page.attach_file 'employer_file_file', @filepath
      wait_for_ajax
      fill_in 'Notes', with: 'Resume'
      click_on 'Add File'
      wait_for_ajax

      expect(page).to have_text 'Resume'

      click_link 'new_employer_file_link'
      @filepath = cover_letter

      page.attach_file 'employer_file_file', @filepath
      wait_for_ajax
      fill_in 'Notes', with: 'Cover Letter'
      click_on 'Add File'
      wait_for_ajax

      expect(page).to have_text 'Cover Letter'
    end
  end
  describe 'can open and delete attachments' do
    before :each do
      signin_admin
      create_employers(1)
    end

    after :each do
      destroy_all_created
    end

    it 'opens and deletes file attachment'  do
      VCR.configure do |config|
        config.allow_http_connections_when_no_cassette = true
      end

      click_link 'new_employer_file_link'
      filepath = cover_letter
      # puts filepath
      page.attach_file 'employer_file_file', filepath
      wait_for_ajax
      fill_in 'Notes', with: 'Cover Letter'
      click_on 'Add File'
      wait_for_ajax

      expect(page).to have_text 'Cover Letter'
      click_on 'Cover Letter'

      new_window = windows.last
      page.within_window new_window do
        expect(page).to have_text 'MY COVER LETTER REALLY COVERS ME'
      end

      delete_btn_id = first(:xpath, "//*[contains(@id, 'destroy_employer_file')]")[:id]
      click_on delete_btn_id

      page.driver.browser.switch_to.alert.accept
      wait_for_ajax
      expect(page).to_not have_text 'Cover Letter'
    end
  end
end
