# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'rack/test'
require 'factory_bot'
require 'faker'
require 'database_cleaner-active_record'


def app
  App
end

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.order = 'random'

  config.include FactoryBot::Syntax::Methods

  config.before(:all) do
    FactoryBot.reload
  end

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  # DatabaseCleaner config
  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
  end

  config.before(:each) do |group|
    DatabaseCleaner.strategy =
      if group.metadata[:js]
        :deletion
      else
        :transaction
      end
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  include Rack::Test::Methods
end
