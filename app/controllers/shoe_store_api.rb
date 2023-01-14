# frozen_string_literal: true

require 'sinatra/json'
require 'sinatra/reloader'

require_relative '../services/init'

class ShoeStoreApi < Sinatra::Application
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

    ::Services::InventoryResponse.call(success:, error:, params:, request:)
  end

  get '/inventories/transfer_suggestions' do
    success = lambda { |response|
      body json(response)
      status 200
    }

    error = lambda { |response|
      body json(error: response)
      status 400
    }

    ::Services::InventoryTransferSuggestionsResponse.call(success:, error:, params:, request:)
  end
end
