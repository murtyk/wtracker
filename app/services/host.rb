# helps in finding server url and generation of links
class Host
  class << self
    def sign_in_link(object, text)
      url = sign_in_url(object)
      return '' unless url
      "<a href= '#{url}'>#{text}</a>"
    end

    def sign_in_url(object)
      subdomain = object.account.subdomain
      host_address = web_address(subdomain)
      return host_address + '/login' if object.is_a? User
      "#{host_address}/trainees/sign_in" if object.is_a? Trainee
      nil
    end

    def web_address(subdomain)
      'http://' + subdomain + '.' + host
    end

    def jobs_host
      "operoapi.#{host}"
    end

    def host
      case Rails.env
      when 'development' then 'localhost.com:3000'
      when 'test'        then 'localhost.com:3000'
      when 'staging'     then 'herokuapp.com'
      when 'production'  then 'managee2e.com'
      end
    end
  end
end
