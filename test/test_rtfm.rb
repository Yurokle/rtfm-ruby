require 'helper'

describe RTFM do
  before do
    @url = "http://vanpe.lt/awesome.jpg"
    RTFM.api_key = "1234"
  end
  
  describe "makes successful requests" do    
    it "moderates without metadata" do
      stub_request(:post, "https://1234:@rtfm.crowdflower.com/v1/images").with(
        :body => /awesome/,
        :headers => {'User-Agent'=>"RTFM/v1 RubyGem/#{RTFM::VERSION}"}
      ).to_return(:status => 200, :body => moderate_success_body(@url))
      res = RTFM.moderate_image(@url)
      res[:image][:id].must_equal(1)
      res[:image][:metadata].must_equal({})
    end
  
    it "moderates with metadata" do
      stub_request(:post, "https://1234:@rtfm.crowdflower.com/v1/images").with(
        :body => /metadata\[foo\]=123/
      ).to_return(:status => 200, :body => moderate_success_body(@url, {:foo => 123}))
      res = RTFM.moderate_image(@url, {:foo => 123})
      res[:image][:metadata].must_equal({:foo => 123})
    end
    
    it "retrieves analysis" do
      stub_request(:get, "https://1234:@rtfm.crowdflower.com/v1/images/1").to_return(:status => 200, :body => retrieve_success_body(1))
      res = RTFM.retrieve_image(1)
      res[:image][:url].must_equal("http://vanpe.lt/fake.jpg")
      res[:image][:id].must_equal(1)
    end
  end
  
  describe "handles network errors" do    
    it "catches ERRNO" do
      stub_request(:post, "https://1234:@rtfm.crowdflower.com/v1/images").to_raise(Errno::ECONNREFUSED)
      error = lambda {
        RTFM.moderate_image(@url)
      }.must_raise(RTFM::APIConnectionError)
      error.to_s.must_match /Connection refused/
    end
    
    it "catches timeout" do
      #The struct is a hack to prevent an infinite loop in RestClient
      stub_request(:post, "https://1234:@rtfm.crowdflower.com/v1/images").to_raise(RestClient::RequestFailed.new(OpenStruct.new(:net_http_res => nil)))
      error = lambda {
        RTFM.moderate_image(@url)
      }.must_raise(RTFM::APIConnectionError)
      error.to_s.must_match /Could not connect/
    end
    
    it "catches SocketError" do
      stub_request(:post, "https://1234:@rtfm.crowdflower.com/v1/images").to_raise(SocketError)
      error = lambda {
        RTFM.moderate_image(@url)
      }.must_raise(RTFM::APIConnectionError)
      error.to_s.must_match /Network error/
    end
    
    it "handles SSL errors"
  end
  
  describe "handles API errors" do
    it "prevents no API key" do
      RTFM.api_key = nil
      lambda {
        RTFM.moderate_image(@url)
      }.must_raise(RTFM::AuthenticationError)
    end
    
    it "handles bad API key" do
      stub_request(:post, "https://1234:@rtfm.crowdflower.com/v1/images").to_return(
        :status => 401, :body => MultiJson.dump({:error => "You're not authorized"})
      )
      error = lambda {
        puts RTFM.moderate_image(@url)
      }.must_raise(RTFM::AuthenticationError)
      error.to_s.must_match /not authorized/
    end
    
    it "handles no money" do
      stub_request(:post, "https://1234:@rtfm.crowdflower.com/v1/images").to_return(
        :status => 402, :body => MultiJson.dump({:error => "You have no money"})
      )
      error = lambda {
        puts RTFM.moderate_image(@url)
      }.must_raise(RTFM::PaymentError)
      error.to_s.must_match /no money/
    end
    
    it "handles bad account" do
      stub_request(:post, "https://1234:@rtfm.crowdflower.com/v1/images").to_return(
        :status => 403, :body => MultiJson.dump({:error => "You have no account"})
      )
      error = lambda {
        puts RTFM.moderate_image(@url)
      }.must_raise(RTFM::AccountError)
      error.to_s.must_match /no account/
    end
    
    it "handles not found" do
      stub_request(:post, "https://1234:@rtfm.crowdflower.com/v1/images").to_return(
        :status => 404, :body => MultiJson.dump({:error => "Not Found"})
      )
      error = lambda {
        puts RTFM.moderate_image(@url)
      }.must_raise(RTFM::InvalidRequestError)
      error.to_s.must_match /Not Found/
    end
    
    it "handles ratelimit" do
      stub_request(:post, "https://1234:@rtfm.crowdflower.com/v1/images").to_return(
        :status => 503, :body => MultiJson.dump({:error => "Too fast"})
      )
      error = lambda {
        puts RTFM.moderate_image(@url)
      }.must_raise(RTFM::RateLimitError)
      error.to_s.must_match /Too fast/
    end
    
    it "handles malformed response on success" do
      stub_request(:post, "https://1234:@rtfm.crowdflower.com/v1/images").to_return(
        :status => 200, :body => "bullshit"
      )
      error = lambda {
        puts RTFM.moderate_image(@url)
      }.must_raise(RTFM::APIError)
      error.to_s.must_match /bullshit/
    end
    
    it "handles malformed response on error" do
      stub_request(:post, "https://1234:@rtfm.crowdflower.com/v1/images").to_return(
        :status => 500, :body => "bullshit"
      )
      error = lambda {
        puts RTFM.moderate_image(@url)
      }.must_raise(RTFM::APIError)
      error.to_s.must_match /bullshit/
    end
    
    it "handles malformed request" do
      stub_request(:post, "https://1234:@rtfm.crowdflower.com/v1/images").to_return(
        :status => 422, :body => MultiJson.dump({:error => "Bad url"})
      )
      error = lambda {
        puts RTFM.moderate_image(@url)
      }.must_raise(RTFM::APIError)
      error.to_s.must_match /Bad url/
    end
  end
end
