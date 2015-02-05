#these will be our global constants for all environments
# VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i  #define a constant

case Rails.env
  when "development"
    AWS_BUCKET = 'managee2e-dev'
    AWS_BUCKET_DELETED = 'managee2e-dev-deleted'
  when "test"
    AWS_BUCKET = 'managee2e-test'
    AWS_BUCKET_DELETED = 'managee2e-test-deleted'
  when "staging"
    AWS_BUCKET = 'managee2e-staging'
    AWS_BUCKET_DELETED = 'managee2e-staging-deleted'
  when "production"
    AWS_BUCKET = 'managee2e-production'
    AWS_BUCKET_DELETED = 'managee2e-production-deleted'

  when "demo"
    AWS_BUCKET = 'managee2e-demo'
    AWS_BUCKET_DELETED = 'managee2e-demo-deleted'
end