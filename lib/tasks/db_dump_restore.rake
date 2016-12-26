namespace :db do
  desc 'dump and restore for development db'

  task :dump do
    dev = Rails.application.config.database_configuration['development']
    dest = "tmp/dev_db.dump"
    db = dev['database']
    user = dev['username']
    pwd = dev['password']
    host = dev['host']

    puts 'PG_DUMP on dev database...'

    cmd = "PGPASSWORD=#{pwd} pg_dump -h #{host} -U #{user} -d #{db} -Fc -f #{dest}"
    puts cmd
    system cmd
    puts 'Done!'
  end

  task :restore do
    dev = Rails.application.config.database_configuration['development']
    dump = "tmp/latest.dump"
    db = dev['database']
    user = dev['username']
    pwd = dev['password']
    host = dev['host']

    puts 'PG_RESTORE on development database...'

    cmd = "PGPASSWORD=#{pwd} pg_restore -h #{host} -U #{user} -d #{db} -c -O #{dump}"

    puts cmd

    system cmd
    puts 'Done!'
  end
end
