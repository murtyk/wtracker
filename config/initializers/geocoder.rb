# frozen_string_literal: true

Geocoder.configure(use_https: true, lookup: :google, api_key: ENV['GOOGLE_KEY'])
