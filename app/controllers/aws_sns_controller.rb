# frozen_string_literal: true

class AwsSnsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def bounce
    json = JSON.parse(request.raw_post)

    if json['TopicArn'] == ENV['AWS_SNS_TOPIC_ARN']
      logger.info 'topic arn matched'
    else
      logger.info 'topic arn mismatch'
    end

    logger.info "bounce callback from AWS with #{json}"

    subscribe_url = json['SubscribeURL']
    if subscribe_url
      confirm_bounce(subscribe_url)
    else
      process_bouce(json)
    end
    render json: {}, status: 200
  end

  def confirm_bounce(subscribe_url)
    logger.info 'AWS is requesting confirmation of the bounce handler URL'
    uri = URI.parse(subscribe_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.get(uri.request_uri)
  end

  def process_bouce(json)
    logger.info "AWS has sent bounce notification(s): #{json}"

    msg = JSON.parse(json['Message'])

    msg['bounce']['bouncedRecipients'].each do |recipient|
      email = recipient['emailAddress']
      reason = recipient['diagnosticCode']

      logger.info "email: #{email}"
      logger.info "diagnosticCode: #{reason}"

      BouncedEmail.process(email, reason).delay
    end
  end
end
