require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'em-threaded-queue'

class Test::Unit::TestCase
  def assert_eventually(time = nil, message = nil, &block)
    start_time = Time.now.to_i

    while (!block.call)
      select(nil, nil, nil, 0.1)
      
      if (time and (Time.now.to_i - start_time > time))
        flunk(message || 'assert_eventually timed out')
      end
    end
  end
end
