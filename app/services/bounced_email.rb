require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

# for each GMAIL_AUTHn env, finds bounced emails and updates trainees
class BouncedEmail
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'wtracker'.freeze
  CLIENT_SECRETS_PATH = './tmp/cs.json'.freeze
  CREDENTIALS_PATH = './tmp/tokens.yaml'.freeze
  SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY

  ADDRESS_NOT_FOUND = 'Address not found'.freeze
  MESSAGE_NOT_DELIVERED =
    'Message not delivered There was a problem delivering your message to '.freeze

  attr_reader :email, :reason

  class << self
    def perform
      client_id = init_client_id

      key = 'GMAIL_AUTH'
      n = 0

      while ENV[key + n.to_s]
        gc = "default: '" + ENV[key + n.to_s] + "'"

        perform_for(client_id, gc)

        n += 1
      end
    end

    def perform_for(client_id, gc)
      service = generate_service(client_id, gc)

      response = service.list_user_messages(
        'me',
        label_ids: ['INBOX'],
        q: 'from:mailer-daemon@googlemail.com'
      )

      return unless response.messages

      response.messages.each do |m|
        msg = service.get_user_message('me', m.id, format: 'full')

        print '.'

        snippet = msg.snippet

        email, reason = parse_snippet(snippet)

        if email && reason
          process(email, reason)
        else
          puts 'email not found for snippet:'
          puts snippet
        end
      end
    end

    def process(email, reason)
      trainee = Trainee.unscoped.where("email ilike '#{email}'").first
      unless trainee
        puts "trainee not found for email: #{email}"
        return
      end

      Account.current_id = trainee.account_id
      Grant.current_id = trainee.grant_id

      puts "updating trainee: #{trainee.name}"
      trainee.update(bounced: true, bounced_reason: reason)
    end

    def init_client_id
      File.delete(CLIENT_SECRETS_PATH) if File.exist?(CLIENT_SECRETS_PATH)
      cs = ENV['CLIENT_SECRET']
      File.open(CLIENT_SECRETS_PATH, 'w') { |file| file.write(cs) }

      Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    end

    def generate_service(client_id, gc)
      cred = "---\n" + gc + "\n"
      File.delete(CREDENTIALS_PATH) if File.exist?(CREDENTIALS_PATH)
      File.open(CREDENTIALS_PATH, 'w') { |file| file.write(cred) }

      service = Google::Apis::GmailV1::GmailService.new
      service.client_options.application_name = APPLICATION_NAME
      service.authorization = authorize(client_id)
      service
    end

    def authorize(client_id)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)

      authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
      user_id = 'default'
      authorizer.get_credentials(user_id)
    end

    def parse_snippet(s)
      return parse_address_not_found(s) if s.include?(ADDRESS_NOT_FOUND)

      index = s.index(MESSAGE_NOT_DELIVERED)

      return parse_message_not_delivered(s) if index

      index = s.index('The response was')
      if index
        email = begin
                  s.split('delivered to ')[1].split(' because')[0]
                rescue
                  ''
                end
        reason = s[index..-1]

        return ['', s] if email.blank?
        return [email, reason]
      end

      [nil, nil]
    end

    def parse_address_not_found(s)
      email = begin
                s.split('delivered to ')[1].split(' because')[0]
              rescue
                ''
              end

      email.blank? ? ['', s] : [email, ADDRESS_NOT_FOUND]
    end

    def parse_message_not_delivered(s)
      begin
        s = '. See the technical details below, or try resending in a few minutes. '
        email, reason = s.split(MESSAGE_NOT_DELIVERED)[1].split(s)
      rescue
        [nil, nil]
      end

      email ? [email, reason] : ['', s]
    end
  end
end
