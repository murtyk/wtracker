# used in routes for api
# api client has to set proper headers
class ApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:default]
  end

  def matches?(req)
    @default || req.headers['Accept'].include?("application/vnd.operoapi.v#{@version}")
  end
end
