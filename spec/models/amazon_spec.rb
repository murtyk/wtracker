require 'rails_helper'
include ActionDispatch::TestProcess
describe Amazon do
  before :each do
    VCR.configure do |config|
      config.allow_http_connections_when_no_cassette = true
    end

    Account.current_id = 1
    @s3 = AWS::S3.new
    @filepath = "#{Rails.root}/spec/fixtures/small.txt"
    @file = fixture_file_upload(@filepath)
  end

  after :each do
    Amazon.delete_bucket('wtracker-rspec-testing')
    VCR.configure do |config|
      config.allow_http_connections_when_no_cassette = false
    end
  end

  it 'creates and deletes a bucket' do
    test_bucket_name = 'wtracker-rspec-testing'
    buckets = @s3.buckets.map(&:name)
    expect(buckets.include?('managee2e-dev')).to be true
    expect(buckets.include?(test_bucket_name)).to be false

    b = Amazon.find_or_create_bucket(test_bucket_name)
    expect(b.exists?).to be true
    Amazon.delete_bucket(test_bucket_name)
    # b.delete
    buckets = @s3.buckets.map(&:name)
    expect(buckets.include?(test_bucket_name)).to be false
  end

  it 'stores and deletes a file' do
    expect(Amazon.send(:aws_bucket)).to eq('managee2e-test')
    file_list = Amazon.file_list
    count = file_list.count
    aws_file_name = Amazon.store_file(@file)

    new_count = Amazon.file_list.count
    expect(new_count - count).to eq(1)
    expect(Amazon.original_file_name(aws_file_name)).to eq('small.txt')

    Amazon.delete_file(aws_file_name)
    new_count = Amazon.file_list.count
    expect(new_count).to eq(count)
  end
end
