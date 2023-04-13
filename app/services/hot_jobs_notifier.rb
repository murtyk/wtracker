# frozen_string_literal: true

# when user adds new hot jobs, trainees will be notified
class HotJobsNotifier
  attr_accessor :notifications

  def initialize
    @notifications = []
  end

  def perform
    build_notifications
    notify
  end

  def notify
    @notifications.each do |_subdomain, subject, body, trainee_emails|
      trainee_emails.each_slice(50).each do |array_emails|
        AutoMailer.notify_hot_jobs(array_emails, subject, body).deliver
      end
    end
  end

  def build_notifications
    Account.all.each do |account|
      Account.current_id = account.id
      next unless any_new_hot_jobs?

      Grant.all.each do |grant|
        Grant.current_id = grant.id
        @grant = grant
        next unless allow_notifications?

        @notifications << notification
      end
    end
  end

  def notification
    [account.subdomain,
     subject,
     body,
     trainee_emails_to_notify]
  end

  def subject
    @grant.hot_jobs_notification_subject
  end

  def body
    s = @grant.hot_jobs_notification_body
    t = Trainee.first
    sign_in_link = Host.sign_in_link(t, 'Click here to sign in and view jobs.')
    s.gsub('$TRAINEE_SIGNIN_LINK$', sign_in_link)
  end

  def trainee_emails_to_notify
    @grant.trainees.where(status: 0).pluck(:email)
  end

  def allow_notifications?
    @grant.trainee_applications? &&
      @grant.hot_jobs_notification_subject &&
      Trainee.any?
  end

  def any_new_hot_jobs?
    HotJob.where('created_at > ?', Date.today).any?
  end
end
