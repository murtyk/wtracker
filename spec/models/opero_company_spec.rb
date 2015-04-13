require 'rails_helper'

describe OperoCompany do
  before :each do
    json = {}
    location = {}
    location['lat'] = 41.05
    location['lng'] = -74.75

    json['name']    = 'Horizon Staffing Solutions Cll'
    json['website'] = 'http://www.horizonstaffingsolutions.com'
    json['types']   = []
    json[:score]    = 94
    json[:line1]    = nil
    json[:city]     = 'Newtown'
    json[:state]    = 'PA'
    json[:zip]      = '18940'
    json[:county]   = 'Bucks'

    json['geometry'] = { 'location' => location }
    json['formatted_phone_number'] = '(718) 263-9212'
    json['formatted_address']      = nil

    @gc = GoogleCompany.new(json)

    allow(GoogleApi).to receive(:find_company).and_return(@gc)
  end

  it 'searches and finds stubbed gc, creates OperoCompany and returns oc' do
    user = OpenStruct.new('default_employer_source_id' => 1)
    company = Company.new('Horizon Staffing Solutions Cll', 'Newtown,PA', user)
    oc = OperoCompany.where(name: 'Horizon Staffing Solutions Cll').first
    expect(oc).to be_nil
    # Company.search calls CompanyFinder.find
    expect { company.search }.to change { OperoCompany.count }.by(1)
    Account.current_id = 1
    oc = OperoCompany.last
    source_id = User.first.default_employer_source_id
    expect { EmployerFactory.create_from_opero(oc.id, source_id, 1) }.to change{
      Employer.count
    }.by(1)
  end
end
