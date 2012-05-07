# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "crowdflower-rtfm"
  gem.homepage = "http://dolores.github.com/rtfm-api"
  gem.license = "MIT"
  gem.summary = %Q{Simple Ruby wrapper for the RTFM API}
  gem.description = %Q{Real Time Foto Moderator (RTFM) is Crowdsourced Image Moderation.  Keep your app clean!}
  gem.email = "vanpelt@crowdflower.com"
  gem.authors = ["Chris Van Pelt"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test
