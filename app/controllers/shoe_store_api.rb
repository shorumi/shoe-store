# frozen_string_literal: true

require 'sinatra/json'
require 'sinatra/reloader'

require_relative '../services/init'

class ShoeStoreApi < Sinatra::Application
  def initialize(app = nil)
    super(app)
  end

  configure :development do
    register Sinatra::Reloader
  end

  # ACTION METHODS COME HERE
  get '/inventories' do
    success = lambda { |response|
      body json(response)
      status 200
    }

    error = lambda { |response|
      body json(error: response)
      status 400
    }

    ::Services::InventoryJsonApiResponse.call(success: success, error: error, params: params, request: request)
  end
end
