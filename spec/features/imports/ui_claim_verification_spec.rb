# frozen_string_literal: true
# require 'rails_helper'
#
# describe 'trainees' do
#   describe 'import' do
#     def stub_reader(trainees)
#       header = %w[tapo_id ui_claim_verified_on funding_source disable]
#       claim_dates = [nil, '3/23/2014', '10/22/2014']
#       fs = [nil, nil, 'NC']
#       disable = %w[Yes No No]
#       rows = (0..2).map do |i|
#         [trainees[i].id, claim_dates[i], fs[i], disable[i]]
#       end
#       stub_importer_file_reader(header, rows)
#     end
#
#     before :each do
#       Delayed::Worker.delay_jobs = false
#
#       allow_any_instance_of(Applicant).to receive(:humanizer_questions)
#         .and_return([{ 'question' => 'Two plus two?',
#                        'answers' => %w[4 four] }])
#
#       os_latlong = OpenStruct.new(latitude: 40.50, longitude: -75.25)
#       allow(GeoServices).to receive(:perform_search).and_return([os_latlong])
#
#       applicants = generate_applicants(6)
#
#       fs = FundingSource.create(name: 'RTW')
#       @nc = FundingSource.create(name: 'NC')
#
#       trainees = applicants.map(&:trainee)
#
#       trainees.each { |t| t.update(funding_source: fs) }
#
#       stub_reader(trainees)
#
#       params = build_importer_params('trainees', 'ui_claim_verification')
#       importer = Importer.new_importer(params, User.first)
#
#       importer.import
#     end
#
#     it 'imports ui claim verifications' do
#       expect(Trainee.where.not(disabled_date: nil).count).to eql(1)
#       expect(Trainee.where(ui_claim_verified_on: '20140323'.to_date).count).to eql(1)
#       expect(Trainee.where(funding_source_id: @nc.id).count).to eql(1)
#     end
#   end
# end
