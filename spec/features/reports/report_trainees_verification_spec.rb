require 'rails_helper'

describe 'Reports' do
  describe 'Trainee' do
    before :each do
      Delayed::Worker.delay_jobs = false
      ENV['SHOW_MAX_ROWS'] = '3'

      switch_to_applicants_domain

      allow_any_instance_of(Applicant).to receive(:humanizer_questions)
        .and_return([{ 'question' => 'Two plus two?',
                       'answers' => %w(4 four) }])
    end

    after :each do
      switch_to_main_domain
    end

    it 'shows verification details' do
      os_latlong = OpenStruct.new(latitude: 40.50, longitude: -75.25)
      allow(GeoServices).to receive(:perform_search).and_return([os_latlong])

      applicants = generate_applicants(6)
      #--------applicants created---------
      fs1 = FundingSource.create(name: 'FS1')
      fs2 = FundingSource.create(name: 'FS2')

      applicants[0..2].each{ |a| a.trainee.update(funding_source: fs1) }
      applicants[3..5].each{ |a| a.trainee.update(funding_source: fs2) }

      signin_applicants_nav

      visit_report Report::TRAINEES_VERIFICATION

      expect(page).to have_text(applicants[0].trainee.name)
      expect(page).to have_text('FS1')
    end
  end
end
