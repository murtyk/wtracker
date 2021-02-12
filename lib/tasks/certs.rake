namespace :certs do
  desc 'push generated certificates to heroku'
  task :push do
    dir = "./tmp/certs-#{Date.today.strftime("%m%d%y")}"
    Dir.mkdir(dir)

    `sudo cp /etc/letsencrypt/live/managee2e.com/cert.pem #{dir}`
    `sudo cp /etc/letsencrypt/live/managee2e.com/chain.pem #{dir}`
    `sudo cp /etc/letsencrypt/live/managee2e.com/fullchain.pem #{dir}`
    `sudo cp /etc/letsencrypt/live/managee2e.com/privkey.pem #{dir}`
    `sudo cp /etc/letsencrypt/live/managee2e.com/README #{dir}`

    puts "Files copied:"
    `ls #{dir}`

    command = "heroku certs:update #{dir}/fullchain.pem #{dir}/privkey.pem -r production"
    puts "running:"
    puts command
    `#{command}`
  end
end
