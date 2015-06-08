class JobsHost
  def self.address
    case Rails.env
    when 'development' then 'operoapi.localhost.com:3000'
    when 'test'        then 'operoapi.localhost.com:3000'
    when 'staging'     then 'operoapi.herokuapp.com'
    when 'production'  then 'operoapi.managee2e.com'
    end
  end
end