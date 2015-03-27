require 'rails_helper'
describe "trainees" do

  describe "import", js: true do
    before(:each) do
      signin_admin

      @filepath = "#{Rails.root}/spec/fixtures/trainees.xlsx"

      allow(Amazon).to receive(:store_file).and_return('thisisawsfilename')
      allow(Amazon).to receive(:file_url).and_return(@filepath)
    end

    after(:each) do
      destroy_trainees
    end

    it "can import trainees", js: true do
      VCR.use_cassette('trainees_import') do
        Delayed::Worker.delay_jobs = false
        visit '/import_statuses/new?resource=trainees'
        attach_file "file", @filepath
        select('Bucks county community college - CNC 101', from: 'klass_id')
        click_button 'Import'
        wait_for_ajax
        visit '/import_statuses/' + ImportStatus.unscoped.last.id.to_s
        expect(page).to have_text 'Lucas'
        expect(page).to have_text 'Errors encountered'
        click_on 'Retry'
        expect(page).to have_text 'Retry Failed'
      end
    end
  end
end