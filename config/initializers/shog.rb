if ::Rails.env.test?
  Shog.configure do
    reset_config!
    timestamp
  end
end