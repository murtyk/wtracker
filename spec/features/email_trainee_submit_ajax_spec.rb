# frozen_string_literal: true
require 'rails_helper'
describe 'email to employer' do
  describe 'attach trainee document', js: true do
    before :each do
      allow_any_instance_of(AccountPolicy).to receive(:edit?)
       .and_return(true)
      allow_any_instance_of(AccountPolicy).to receive(:update?)
       .and_return(true)

      signin_admin
      visit '/accounts/trainee_options'
      check 'Consider emailing trainee document to an employer as job applied'
      click_on 'Update'
      create_klasses(1, 1)
      create_employers(1)
      create_contacts(get_employers, 1)

      @filepath = "#{Rails.root}/spec/fixtures/RESUME.docx"
      allow(Amazon).to receive(:store_file).and_return('RESUME.docx')
      allow(Amazon).to receive(:file_url).and_return(@filepath)
      allow(Amazon).to receive(:original_file_name).and_return('RESUME.docx')
      allow(Amazon).to receive(:delete_file).and_return(nil)
    end
    after :each do
      destroy_all_created
    end

    it 'considered as trainee submit - job applied' do
      visit trainee_path(get_trainees.first)

      click_link 'new_trainee_file_link'
      page.attach_file 'trainee_file_file', @filepath
      wait_for_ajax
      fill_in 'Notes', with: 'Resume'
      click_on 'Add File'
      wait_for_ajax

      visit('/emails/new')
      find_field('Subject').set 'reference101'
      fill_in 'Content', with: 'Hello, how are you?'

      fill_in 'name', with: 'Company'
      click_on 'Find'

      wait_for_ajax
      5.times do
        break if page.html.index('Client1 Client1(Company1)')
        sleep 1
      end

      select('Client1 Client1(Company1)', from: 'select_contacts')
      click_button 'add-selected-contacts'

      select('Engineering1', from: 'select_klass_id')

      doc_check_box = find(:css, "[value='RESUME.docx']")

      trainee = get_trainees.first
      trainee_file = trainee.trainee_files.first
      page.check("tf_#{trainee_file.id}")
      doc_check_box.set(true)

      # unless doc_check_box.checked?
      #   puts "*********************************"
      #   puts "MURTY!"
      #   puts "check box is not checked!!!!!"
      # end

      click_button 'Send'

      visit trainee_path(get_trainees.first)
      sleep 2
      expect(page).to have_text 'Company'
    end
  end
end
