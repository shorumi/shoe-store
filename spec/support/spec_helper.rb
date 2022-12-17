# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require File.join(File.dirname(__FILE__), '..', '..', 'app')

require 'rack/test'
require 'factory_bot'

ENV['RACK_ENV'] ||= 'test'

RSpec.configure do |config|
  config.before(:each) do
    #MODEL.all.delete
  end

  config.order = 'random'

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  include Rack::Test::Methods
end
