require 'rails_helper'

# most of the trainees are either loaded from a file or entered
# online which creates using factory
describe TraineeFactory do
  before :each do
    Account.current_id = 1
    Grant.current_id = 1
  end
  it 'returns a valid trainee with address' do
    address_attrs = fake_address
    params = { first: Faker::Name.first_name,
               last:  Faker::Name.last_name,
               home_address_attributes: address_attrs }
    trainee = TraineeFactory.new_trainee(params)
    trainee.save
    expect(trainee.line1).to eq(address_attrs[:line1])
  end

  it 'returns a valid trainee with tact3' do
    tact_three_attrs = { education_level: 1, years: 5 }
    params = { first: Faker::Name.first_name,
               last:  Faker::Name.last_name,
               tact_three_attributes: tact_three_attrs }
    trainee = TraineeFactory.new_trainee(params)
    trainee.save
    expect(trainee.years).to eq(tact_three_attrs[:years])
  end
end
