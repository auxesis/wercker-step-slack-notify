RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    # be_bigger_than(2).and_smaller_than(4).description
    #   # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #   # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.before(:all) do
    # Provide a full path to the tmp directory, so Aruba file lookups work
    @dirs = [ Pathname.new(__FILE__).parent.parent.to_s, 'tmp', 'aruba']

    # Spawn a Rack server in the background, for the notifier to talk to
    rack = Thread.new do
      # Shut The Fuck Up Webrick http://tomlea.co.uk/posts/shut-the-fuck-up-webrick/
      require 'webrick'
      options = {
        :app => Slack,
        :Port => 9988,
        :server => 'webrick',
        :AccessLog => [],
        :Logger => WEBrick::Log::new("/dev/null")
      }
      Rack::Server.new(options).start
    end

    # Block running the tests until the Rack server has booted
    require "net/http"
    require "uri"

    uri = URI.parse("http://localhost:9988/")
    begin
      Net::HTTP.get_response(uri)
    rescue Errno::ECONNREFUSED
      # Wait up to 10 seconds for the Rack server to boot
      @retry_start ||= Time.now
      if Time.now - @retry_start < 10
        retry
      else
        fail("Couldn't boot up Rack server for testing")
      end
    end
  end
end

require 'erb'
require 'pry'
require 'pathname'

# Load in Aruba bits
Dir.glob(::File.expand_path('../support/*.rb', __FILE__)).each { |f| require_relative f }

root = Pathname.new(__FILE__).parent.parent
ENV['PATH'] = "#{root.to_s}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
