require "bundler/setup"
require "sandthorn_demo"
require "bundler"
require "sandthorn"
require "sandthorn_driver_sequel"
require "sandthorn/event_inspector"
require "oj"

RSpec.configure do |config|

  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
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

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!
  config.expose_dsl_globally = true
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all) {
    sqlite_store_setup
  }

  config.before(:each) {
    migrator = SandthornDriverSequel::Migration.new url: url  
    migrator.send(:clear_for_test)

    #Setup an event_store from SanthornDriverSequel
    SandthornSequelProjection.configure do |conf|
      conf.db_connection = Sequel.sqlite
      conf.event_store = sandthorn_driver
    end
  }

  config.after(:all) do
    Sandthorn.event_stores.default_store.driver.instance_variable_get(:@db).disconnect
  end

end

def url
  "sqlite://spec/sequel_driver.sqlite3"
end

def sandthorn_driver
  @driver || sqlite_store_setup
end

def sqlite_store_setup

  SandthornDriverSequel.migrate_db url: url

  driver = SandthornDriverSequel.driver_from_url(url: url) do |conf|
    conf.event_serializer       = Proc.new { |data| Oj::dump(data) }
    conf.event_deserializer     = Proc.new { |data| Oj::load(data) }
  end
  
  Sandthorn.configure do |c|
    c.event_store = driver
  end

  return driver

end