require 'rails_helper'

describe 'trainees' do
  describe 'import' do
    def stub_reader(trainees)
      header = %w(tapo_id ui_claim_verified_on)
      values = [nil, '3/23/2014', 'NC']
      rows = (0..2).map do |i|
                [trainees[i].id, values[i]]
             end
      stub_importer_file_reader(header, rows)
    end

    before :each do
      Delayed::Worker.delay_jobs = false

      allow_any_instance_of(Applicant).to receive(:humanizer_questions)
        .and_return([{ 'question' => 'Two plus two?',
                       'answers' => %w(4 four) }])

      os_latlong = OpenStruct.new(latitude: 40.50, longitude: -75.25)
      allow(GeoServices).to receive(:perform_search).and_return([os_latlong])

      applicants = generate_applicants(6)

      fs = FundingSource.create(name: 'RTW')

      trainees = applicants.map(&:trainee)

      trainees.each{ |t| t.update(funding_source: fs) }

      stub_reader(trainees)

      user = User.first

      params = build_importer_params('trainees', 'ui_claim_verification')
      importer = Importer.new_importer(params, User.first)

      importer.import
    end

    it 'imports ui claim verifications' do
      expect(Trainee.where.not(disabled_date: nil).count).to eql(2)
      expect(Trainee.where(ui_claim_verified_on: '3/23/2014').count).to eql(1)
    end
  end
end
