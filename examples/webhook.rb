require 'rubygems'
require 'sinatra'
require 'multi_json'
require 'openssl'
require 'base64'

PKey = OpenSSL::PKey::RSA.new(File.read(File.join(File.dirname(__FILE__), "webhook_public.pem")))

post "/rtfm_webhook" do
  signature = env['X-CrowdFlower-Signature']
  body = request.body.read
  if(@public_key.verify(OpenSSL::Digest::SHA1.new, Base64.decode64(signature), body))
    payload = MultiJson.load(body)
    #Do something meaningful with the payload here
    logger.debug "SUCCESS"
    logger.debug payload
    200
  else
    logger.debug "FAILURE #{signature}"
    logger.debug body
    401
  end
end