require 'rails_helper'

describe 'Reports' do
  describe 'Trainees Near By Employers', js: true do
    before :each do
      Delayed::Worker.delay_jobs = false
      signin_admin
    end

    after :each do
      signout
    end

    describe 'Show Max Rows is less than results count' do
      it 'displays partial rows' do
        ENV['SHOW_MAX_ROWS'] = '1'
        visit_report Report::TRAINEES_NEAR_BY_EMPLOYERS
        select 'CNC 101', from: 'Class'
        select 'manufacturing', from: 'Sector'
        fill_in 'Distance', with: '25'
        click_on 'Find'
        sleep 3
        wait_for_ajax
        expect(page).to have_text 'Paul Harris'
        expect(page).to have_text 'Trigyn'

        expect(page).to_not have_text 'Tom Cruise'
        expect(page).to have_text 'Too many records to display.'
      end
    end

    describe 'Show Max Rows is more than results count' do
      it 'displays all rows' do
        ENV['SHOW_MAX_ROWS'] = '3'
        visit_report Report::TRAINEES_NEAR_BY_EMPLOYERS
        select 'CNC 101', from: 'Class'
        select 'manufacturing', from: 'Sector'
        fill_in 'Distance', with: '25'
        click_on 'Find'
        sleep 3
        wait_for_ajax
        expect(page).to have_text 'Paul Harris'
        expect(page).to have_text 'Tom Cruise'
      end
    end

    describe 'max rows for download is more than results count' do
      it 'allows download' do
        ENV['MAX_ROWS_FOR_DOWNLOAD'] = '5'
        visit_report Report::TRAINEES_NEAR_BY_EMPLOYERS
        select 'CNC 101', from: 'Class'
        select 'manufacturing', from: 'Sector'
        fill_in 'Distance', with: '25'
        click_on 'Find'
        sleep 7
        wait_for_ajax
        expect(page).to have_text 'Paul Harris'
        expect(page).to have_text 'Tom Cruise'

        expect(page).to have_css('.btn-download')
        first('.btn-download').click

        Account.current_id = 1
        Grant.current_id = 1
        user_id = admin_user.id
        file_name = "trainees_and_near_by_employers_#{user_id}.xlsx"

        file_path = Rails.root.join('tmp/').to_s + file_name
        reader = ImportFileReader.new(file_path, file_name)

        names = []
        loop do
          row = reader.next_row
          break unless row
          names << row['trainee']
        end

        expect(names.include? 'Paul Harris').to be_truthy

        visit_report Report::TRAINEES_NEAR_BY_EMPLOYERS
      end
    end

    describe 'max rows for download is less than results count' do
      it 'sends download file as email' do
        ENV['MAX_ROWS_FOR_DOWNLOAD'] = '1'
        visit_report Report::TRAINEES_NEAR_BY_EMPLOYERS
        select 'CNC 101', from: 'Class'
        select 'manufacturing', from: 'Sector'
        fill_in 'Distance', with: '25'
        click_on 'Find'
        sleep 6
        wait_for_ajax
        expect(page).to have_text 'Paul Harris'
        expect(page).to have_text 'Tom Cruise'

        expect(page).to have_css('.btn-email-download')

        first('.btn-email-download').click

        sleep 5

        page.driver.browser.switch_to.alert.accept
        mail = ActionMailer::Base.deliveries.last

        Account.current_id = 1
        Grant.current_id = 1
        user_id = admin_user.id
        file_name = "trainees_and_near_by_employers_#{user_id}.xlsx"

        expect(mail.subject).to eq('Trainees And Near By Employers')
        expect(mail.attachments.first.filename).to eql(file_name)
      end
    end

  end
end
