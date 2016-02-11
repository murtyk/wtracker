require 'rails_helper'

describe 'trainees' do
  describe 'import updates' do
    def stub_reader(trainees)
    # ID  dob_date    edp_date    assessment_name assessment_date trainee_id
    # 76  11/22/1966  6/30/2015   LRI Assessment   5/31/2015       123231234
    # 81  10/21/1988              LRI Assessment   5/31/2015       999334545
    # 45              7/15/2015

      header      = %w(id dob_date edp_date assessment_name assessment_date trainee_id)
      dob_dates   = ['11/22/1966', '10/21/1988']
      edp_dates   = ['6/30/2015',   '',        '7/15/2015']
      a_dates     = ['5/31/2015',   '5/31/2015']
      trainee_ids = ['123231234', '999334545']

      rows = (0..2).map do |i|
                [trainees[i].id,
                 dob_dates[i],
                 edp_dates[i],
                 'LRI Assessment',
                 a_dates[i],
                 trainee_ids[i] ]
             end
      stub_importer_file_reader(header, rows)
    end

    before :each do
      Delayed::Worker.delay_jobs = false
      Account.current_id = 1
      grant = FactoryGirl.create(:grant)
      Grant.current_id = grant.id

      @trainees = (0..2).map{FactoryGirl.create(:trainee)}
      assessment = Assessment.create(name: 'LRI Assessment')

      stub_reader(@trainees)

      params = build_importer_params('trainees', 'updates')
      importer = Importer.new_importer(params, User.first)

      importer.import
    end

    it 'imports trainee updates' do
      expect(TraineeAssessment.count).to eql(2)
      trainee = Trainee.find @trainees[0].id
      expect(trainee.trainee_id).to eql('123231234')
      expect(trainee.dob.to_s).to eql('11/22/1966')
      trainee = Trainee.find @trainees[2].id
      expect(trainee.reload.edp_date.to_s).to eql('07/15/2015')
    end
  end
end
