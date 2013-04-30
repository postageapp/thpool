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
  gem.name = "em-worker-pool"
  gem.homepage = "http://github.com/twg/em-worker-pool"
  gem.license = "MIT"
  gem.summary = %Q{EventMachine Thread Pool/Worker System}
  gem.description = %Q{Simple thread pool/worker system for EventMachine}
  gem.email = "scott@twg.ca"
  gem.authors = [ "Scott Tadman" ]
  # dependencies defined in Gemfile
end

Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end
