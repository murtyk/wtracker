require 'rails_helper'

describe 'Trainees' do
  before :each do
    signin_admin
    Delayed::Worker.delay_jobs = false

    Account.current_id = 1
    Grant.current_id = 1

    program = Program.first
    college = College.first

    @klass1 = FactoryGirl.create(:klass, program_id: program.id, college_id: college.id)
    @klass2 = FactoryGirl.create(:klass, program_id: program.id, college_id: college.id)

    @k1_trainees = 3.times.map { FactoryGirl.create :trainee }
    @klass1.trainees << @k1_trainees

    @k2_trainees = 3.times.map { FactoryGirl.create :trainee }
    @klass2.trainees << @k2_trainees

    @klass1_label = @klass1.to_label

    @user_id = admin_user.id
  end

  after :each do
    signout
  end

  describe 'advanced search' do
    it 'searches' do
      visit '/trainees/advanced_search'

      @k2_trainees.each do |t|
        expect(page).to have_text t.first
      end

      select(@klass1_label, from: 'q_klasses_id_eq')
      click_button('Search', match: :first)

      @k1_trainees.each do |t|
        expect(page).to have_text t.first
      end

      @k2_trainees.each do |t|
        expect(page).to_not have_text t.first
      end
    end
  end

  describe 'downloads' do
    it 'excel file' do
      ENV['MAX_ROWS_FOR_DOWNLOAD'] = '200'
      visit '/trainees/advanced_search'

      expect(page).to have_css('.btn-download')
      find(:xpath, "//a[@href='/trainees/advanced_search.xls']").click

      content_type = page.response_headers['Content-Type']

      expect(content_type).to eql('application/vnd.ms-excel')

      file_name = "trainee_data_#{@user_id}.xlsx"

      file_path = Rails.root.join('tmp/').to_s + file_name
      reader = ImportFileReader.new(file_path, file_name)

      first_names = []
      last_names = []

      loop do
        row = reader.next_row
        break unless row
        first_names << row['first name']
        last_names << row['last name']
      end

      @k1_trainees.each do |t|
        expect(first_names.include? t.first).to be_truthy
      end
      @k2_trainees.each do |t|
        expect(last_names.include? t.last).to be_truthy
      end
      visit '/trainees/advanced_search'
    end
  end

  describe 'emails' do
    it 'excel file', js: true do
      ENV['MAX_ROWS_FOR_DOWNLOAD'] = '2'

      visit '/trainees/advanced_search'
      expect(page).to_not have_css('.btn-download')
      expect(page).to have_css('.btn-email-download')

      # Delayed::Worker.new.work_off
      # Delayed::Worker.new(quiet: false).work_off
      first('.btn-email-download').click

      sleep 2
      page.driver.browser.switch_to.alert.accept

      mail = ActionMailer::Base.deliveries.last

      file_name = "trainee_data_#{@user_id}.xlsx"

      expect(mail.subject).to eq('Trainees - Advanced Search - Data')
      expect(mail.attachments.first.filename).to eql(file_name)
    end
  end
end
