# frozen_string_literal: true

if ::Rails.env.test?
  Shog.configure do
    reset_config!
    timestamp
  end
end
