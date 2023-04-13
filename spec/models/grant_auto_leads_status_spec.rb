# frozen_string_literal: true

require 'rails_helper'

describe GrantAutoLeadsStatus do
  let(:account_id) { Account.find_by(subdomain: 'njit').id }
  let(:grant_id) { Grant.first.id }

  let(:trainees) { create_list(:trainee, 5) }

  before :each do
    Account.current_id = account_id
    Grant.current_id = grant_id

    trainees.each do |trainee|
      key = "g#{grant_id}_#{trainee.id}"
      Rails.cache.write(key, rand(10..25))
    end
  end

  def assert_cache_cleared
    trainees.each do |trainee|
      key = "g#{grant_id}_#{trainee.id}"
      expect(Rails.cache.read(key)).to be(nil)
    end
  end

  it 'sends status email and clears cache' do
    allow(JobLeadsStatusMailer).to receive(:notify) do |g, lead_counts|
      expect(g.id).to eql(grant_id)

      names = lead_counts.map { |s| s.split(' - ').first }
      t_names = trainees.map(&:name)
      expect(names.sort).to eql(t_names.sort)
      OpenStruct.new # keep it. avoids calling deliver_now on nil
    end

    GrantAutoLeadsStatus.perform(grant_id)
    assert_cache_cleared
  end
end
