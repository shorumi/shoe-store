# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'sinatra/custom_logger'
require 'pry-byebug'

require 'bundler/setup'
require 'active_job'
require 'sneakers'

require_relative './config/init'
require_relative './config/routes/init'
require_relative './app/workers/init'

# :nocov:
if Sinatra::Base.environment == :development
  require 'dotenv'
  Dotenv.load
end
# :nocov:

class App < Sinatra::Application
  set :server, :puma
  set :logger, Logger.new($stdout)

  register Sinatra::ActiveRecordExtension

  configure :development do
    register Sinatra::Reloader
  end

  enable :logging

  use ShoeStoreApi
end
