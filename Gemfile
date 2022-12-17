# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Active Support is a collection of utility classes and standard library extensions that were found useful for the Rails framework
gem 'activesupport'

# Sinatra is a DSL for quickly creating web applications in Ruby with minimal effort
gem 'sinatra', '~> 2.1.0'
# A Ruby Web Server Built For Concurrency
gem 'puma'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.4.5'
# Rake is a Make-like program implemented in Ruby. Tasks and dependencies are specified in standard Ruby syntax.
gem 'rake'

group :development do
  # For every future Sinatra release, have at least one fully compatible release
  gem 'sinatra-contrib'
end

group :test do
  # actory_bot is a fixtures replacement with a straightforward definition syntax, support for multiple build strategies
  gem 'factory_bot'
  # Behaviour Driven Development for Ruby
  gem 'rspec'
  # Rack::Test is a small, simple testing API for Rack apps
  gem 'rack-test'
  # SimpleCov is a code coverage analysis tool for Ruby
  gem 'simplecov', require: false
end

group :development, :test do
  # Pry is a runtime developer console and IRB alternative with powerful introspection capabilities
  gem 'pry'
  # Adds step-by-step debugging and stack navigation capabilities to pry using byebug.
  gem 'pry-byebug'
  # Shim to load environment variables from .env into ENV in development.
  gem 'dotenv-rails'
end
