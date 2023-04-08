# frozen_string_literal: true

require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

namespace :gmail do
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  APPLICATION_NAME = 'Gmail API Ruby Quickstart'
  CLIENT_SECRETS_PATH = 'client_secret.json'
  CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                               'tokens.yaml')
  SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY

  desc 'pubsub gmail watch. run this only in dev env.'
  task :watch do
    # Initialize the API
    service = Google::Apis::GmailV1::GmailService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    # Show the user's labels
    user_id = 'me'
    result = service.list_user_labels(user_id)

    puts 'Labels:'
    puts 'No labels found' if result.labels.empty?
    result.labels.each { |label| puts "- #{label.name}" }

    # for watch

    watch_request = Google::Apis::GmailV1::WatchRequest.new
    watch_request.topic_name = 'projects/wtracker-1352/topics/bounced'
    watch_request.label_ids = ['INBOX']
    watch_request.label_filter_action = 'include'
    watch_response = service.watch_user('me', watch_request)
    puts watch_response.inspect
  end

  # use this to generate credentials for an email,
  #   copy the content of the credential file to env variable GMAIL_AUTHn
  task :bounces do
    service = Google::Apis::GmailV1::GmailService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = rake_authorize

    bounced_emails = []

    # find bounced messages
    response = service.list_user_messages('me', label_ids: ['INBOX'],
                                                q: 'from:mailer-daemon@googlemail.com')

    response.messages.each do |m|
      print m.id

      msg = service.get_user_message('me', m.id, format: 'full')

      print '.'

      snippet = msg.snippet

      email, reason = parse_snippet(snippet)

      if email && reason
        bounced_emails << [email, reason]
      else
        puts snippet
      end
    end

    csv_data = CSV.generate do |csv|
      csv << %w[email reason]
      bounced_emails.each { |row| csv << row }
    end

    file_path = "./tmp/bounced_#{Time.now.to_s.gsub(/[ :+-]/, '_')}.csv"
    File.open(file_path, 'wb') do |file|
      file.write(csv_data)
    end

    puts file_path
  end

  ##
  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def rake_authorize
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

    client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)

    token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(
      client_id, SCOPE, token_store
    )
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(
        base_url: OOB_URI
      )
      puts 'Open the following URL in the browser and enter the ' \
           'resulting code after authorization'
      puts url
      code = $stdin.gets.strip
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
  end

  def parse_snippet(s)
    if s.include?('Address not found')
      email = begin
        s.split('delivered to ')[1].split(' because')[0]
      rescue StandardError
        ''
      end

      return ['', s] if email.blank?

      return [email, 'Address not found']
    end

    prefix = 'Message not delivered There was a problem delivering your message to '
    index = s.index(prefix)

    if index
      begin
        s = '. See the technical details below, or try resending in a few minutes. '
        email, reason = s.split(prefix)[1].split(s)
      rescue StandardError
        [nil, nil]
      end
      return [email, reason] if email

      return ['', s]
    end

    index = s.index('The response was')
    if index
      email = begin
        s.split('delivered to ')[1].split(' because')[0]
      rescue StandardError
        ''
      end
      reason = s[index..-1]

      return ['', s] if email.blank?

      return [email, reason]
    end

    [nil, nil]
  end
end
