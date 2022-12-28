# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'sinatra/custom_logger'
require 'pry-byebug'

require_relative './config/init'
require_relative './config/routes/init'
require_relative 'app/workers/persist_shoe_sales_worker'

# :nocov:
if Sinatra::Base.environment == :development
  require 'dotenv'
  Dotenv.load
end
# :nocov:

class App < Sinatra::Application
  set :server, :puma
  set :logger, Logger.new(STDOUT)

  register Sinatra::ActiveRecordExtension

  configure :development do
    register Sinatra::Reloader
  end

  enable :logging

  use ShoeStoreApi
end
