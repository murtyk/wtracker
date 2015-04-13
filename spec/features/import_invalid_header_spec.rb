require 'rails_helper'
describe 'Import Services' do
  describe 'import' do
    before(:each) do
      signin_admin

      @filepath = "#{Rails.root}/spec/fixtures/trainees.xlsx"
      allow(Amazon).to receive(:store_file).and_return('thisisawsfilename')
      allow(Amazon).to receive(:file_url).and_return(@filepath)
    end

    it 'bad header' do
      VCR.use_cassette('import_badheader') do
        visit '/import_statuses/new?resource=klasses'
        attach_file 'file', @filepath
        select('Big program 1', from: 'program_id')
        select('Bucks county community college', from: 'college_id')
        click_button 'Import'
        expect(page).to have_text 'Invalid Header'
      end
    end
  end
end
