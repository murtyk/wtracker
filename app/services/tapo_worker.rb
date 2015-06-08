class TapoWorker
  include HTTParty
  attr_reader :id

  def initialize(n)
    @id = n
  end

  def queue_job(job_name)
    return if Rails.env.development? || Rails.env.test?
    sign_in
    send_job(job_name)
    sign_out
  end

  def send_job(job_name)
    url = "http://#{worker_host}/jobs.json"

    body = { job: { data: {}, jobs_host: JobsHost.address, name: job_name } }
    TapoWorker.post(url,
                    headers: api_authorization_header,
                    body: body.to_json)
  end

  def api_authorization_header
    api_headers.merge('Authorization' =>  @auth_token)
  end

  def sign_in
    response = TapoWorker.post(sign_in_url, headers: api_headers)
    ps = response.parsed_response
    @auth_token = ps['user']['auth_token']
  end

  def sign_out
    TapoWorker.delete(sign_out_url, headers: api_headers)
  end

  def sign_out_url
    "http://#{worker_host}/sessions/#{@auth_token}"
  end

  def sign_in_url
    "http://#{worker_host}/sessions.json?#{credentials}"
  end

  def credentials
    email = 'admin@operoinc.com'
    password = ENV['OPERO_API_PASSWORD']
    "session[email]=#{email}&session[password]=#{password}"
  end

  def api_headers
    { 'Content-Type' => 'application/json', 'Accept' => 'application/vnd.operoapi.v1' }
  end

  def worker_host
    case Rails.env
    when 'development' then 'tapoworker.localhost.com:3000'
    when 'test'        then 'tapoworker.localhost.com:3000'
    when 'staging'     then "tapoworker-#{id}.herokuapp.com"
    when 'production'  then "tapoworker-#{id}.herokuapp.com"
    end
  end

  def jobs_host
    case Rails.env
    when 'development' then 'operoapi.localhost.com:3000'
    when 'test'        then 'operoapi.localhost.com:3000'
    when 'staging'     then 'operoapi.herokuapp.com'
    when 'production'  then 'operoapi.managee2e.com'
    end
  end
end
