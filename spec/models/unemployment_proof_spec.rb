# frozen_string_literal: true

require 'rails_helper'

describe UnemploymentProof do
  before :each do
    Account.current_id = Account.where(subdomain: 'apple').first.id
    Grant.current_id = Grant.where(name: 'Right To Work').first.id
  end
  it 'returns in order created' do
    name = 'aaaaaaaaaaaaa'
    UnemploymentProof.create(name: name)
    expect(UnemploymentProof.last.name).to eq(name)
  end
end
