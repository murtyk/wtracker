Shog.configure do
  if ::Rails.env.test?
    reset_config!
    timestamp
  end

  match /execution expired/ do |msg,matches|
    # Highlight timeout errors
    msg.red
  end
end