require 'rails_helper'

describe ApplicantSource do
  before :each do
    Account.current_id = Account.where(subdomain: 'apple').first.id
    Grant.current_id = Grant.where(name: 'Right To Work').first.id
  end
  it "returns in order created" do
    source = 'aaaaaaaaaaaaa'
    ApplicantSource.create(source: source)
    expect(ApplicantSource.all.to_a[-1].source).to eq(source)
  end
end
