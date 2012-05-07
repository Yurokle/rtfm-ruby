require 'rubygems'
require 'openssl'
require 'rest_client'
require 'multi_json'

module RTFM
  VERSION = File.read(File.join(File.dirname(__FILE__),"..","VERSION"))
  @@api_key = nil
  @@api_base = "https://rtfm.crowdflower.com/v1"

  def self.api_key=(api_key); @@api_key = api_key; end
  def self.api_key; @@api_key; end
  def self.api_base=(api_base); @@api_base = api_base; end
  def self.api_base; @@api_base; end
  def self.api_url(url=''); @@api_base + url; end
  
  def self.moderate_image(url, metadata = nil)
    params = {:url => url}
    params.merge!(:metadata => metadata) if metadata
    request("/images", :post, params)
  end
  
  def self.retrieve_image(id)
    request("/images/#{id}")
  end
  
  def self.request(url, method = :get, params = nil, api_key = nil, headers = {})
    api_key ||= @@api_key
    raise AuthenticationError.new("Please provide an API key (RTFM.api_key = <API-KEY>, your API key can be found by clicking \"APISettings\" @ http://crowdflower.com/rtfm)") unless api_key
    
    #RestClient appends get parameters by looking for params in headers... lame
    if method == :get && params
      headers.merge!(:params => params)
      params = nil      
    end
      
    opts = {
      :user => api_key,
      :timeout => 30,
      :url => api_url(url),
      :method => method,
      :headers => {
        :user_agent => "RTFM/v1 RubyGem/#{VERSION}",
        :accept => "application/json"
      }.merge(headers),
      :payload => params
    }
    
    response = RestClient::Request.execute(opts)
    MultiJson.load(response.body, :symbolize_keys => true)
  rescue SocketError => e
    self.handle_restclient_error(e)
  rescue RestClient::ExceptionWithResponse => e
    rcode = e.http_code
    rbody = e.http_body
    if rcode && rbody 
      self.handle_api_error(rcode, rbody)
    else
      self.handle_restclient_error(e)
    end
  rescue RestClient::Exception, Errno::ECONNREFUSED => e
    self.handle_restclient_error(e)
  rescue MultiJson::DecodeError
    raise APIError.new("Invalid response body: #{response.body.inspect}. (HTTP response code of #{response.code})", response.code, response.body)
  end
  
  class Error < StandardError
    attr_reader :message
    attr_reader :http_status
    attr_reader :http_body
    attr_reader :json_body

    def initialize(message=nil, http_status=nil, http_body=nil, json_body=nil)
      @message = message
      @http_status = http_status
      @http_body = http_body
      @json_body = json_body
    end

    def to_s
      status_string = @http_status.nil? ? "" : "(Status #{@http_status}) "
      "#{status_string}#{@message}"
    end
  end
  
  class RateLimitError < Error; end
  class APIError < Error; end
  class PaymentError < Error; end
  class AccountError < Error; end
  class AuthenticationError < Error; end
  class InvalidRequestError < Error; end
  class APIConnectionError < Error; end
  
  def self.error(klass = Error, error, rcode, rbody, error_obj); klass.new(error, rcode, rbody, error_obj); end
  
  def self.handle_api_error(rcode, rbody)
    begin
      error_obj = MultiJson.load(rbody, :symbolize_keys => true)
      error = error_obj[:error] or raise Error.new # escape from parsing
    rescue MultiJson::DecodeError, Error
      raise APIError.new("Invalid response object from API: #{rbody.inspect} (HTTP response code was #{rcode})", rcode, rbody)
    end

    case rcode
    when 503
      raise error(RateLimitError, error, rcode, rbody, error_obj)
    when 400, 404 then
      raise error(InvalidRequestError, error, rcode, rbody, error_obj)
    when 401
      raise error(AuthenticationError, error, rcode, rbody, error_obj)
    when 402
      raise error(PaymentError, error, rcode, rbody, error_obj)
    when 403
      raise error(AccountError, error, rcode, rbody, error_obj)
    else
      raise error(APIError, error, rcode, rbody, error_obj)
    end
  end

  def self.handle_restclient_error(e)
    case e
    when RestClient::ServerBrokeConnection, RestClient::RequestFailed
      message = "Could not connect to RTFM (#{@@api_base}).  Please check your internet connection and try again.  If this problem persists, you should check RTFM's service status at https://twitter.com/cfstatus, or let us know at rtfm@crowdflower.com."
    when RestClient::SSLCertificateNotVerified
      message = "Could not verify RTFM's SSL certificate.  Please make sure that your network is not intercepting certificates. If this problem persists, let us know at rtfm@crowdflower.com."
    when SocketError
      message = "Unexpected error communicating when trying to connect to RTFM.  HINT: You may be seeing this message because your DNS is not working.  To check, try running 'host stripe.com' from the command line."
    else
      message = "Unexpected error communicating with RTFM.  If this problem persists, let us know at rtfm@crowdflower.com"
    end
    message += "\n\n(Network error: #{e.message})"
    raise APIConnectionError.new(message)
  end
end
    