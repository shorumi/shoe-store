# frozen_string_literal: true

require 'sinatra/json'
require 'sinatra/reloader'

require './app/models/init'
require './app/repositories/init'
require './app/business/rules/init'
require './app/custom/exception_messages/init'

class ShoeStoreApi < Sinatra::Application
  def initialize(
    app = nil
  )
    super(app)
  end

  configure :development do
    register Sinatra::Reloader
  end

  # ACTION METHODS COME HERE
end
