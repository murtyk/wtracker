# frozen_string_literal: true

# app/concerns/encryption.rb
require 'active_support/concern'

module Encryption
  extend ActiveSupport::Concern

  def encryption_key
    return ENV['ENCRYPTION_KEY'] if ENV['ENCRYPTION_KEY']
    raise 'Must set encryption key!!' if Rails.env.production?

    '8019da87bc8d541b55000b529edf9ba0f5d4bdb1a15cde56ad38dee1c0fe5e664bd1705445e'
  end
end
