require 'rubygems'
require 'bundler'
require 'simplecov'
SimpleCov.start

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'minitest/spec'
require 'minitest/autorun'
require 'webmock/minitest'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'crowdflower-rtfm'

def moderate_success_body(url, metadata = {})
  MultiJson.dump(
    "image" => {
      "id" => 1,
      "url" => url,
      "metadata" => metadata
    }
  )
end

def retrieve_success_body(id)
  MultiJson.dump(
    "image" => {
      "id" => id,
      "url" => "http://vanpe.lt/fake.jpg",
      "score" => 0.6,
      "rating" => "accepted",
      "state" => "completed",
      "metadata" => {}
    }
  )
end

class MiniTest::Spec::TestCase
end