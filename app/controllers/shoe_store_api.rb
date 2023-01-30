# frozen_string_literal: true

require 'sinatra/json'

require_relative 'application_controller'
require_relative '../../libs/validators/allowed_string_query_params'
require_relative '../services/init'

class ShoeStoreApi < ApplicationController
  # ACTION METHODS COME HERE
  get '/inventories' do
    ::Validators::AllowedStringQueryParams.validate(error:, params:)
    ::Services::InventoryResponse.call(success:, error:, params:, request:)
  end

  get '/inventories/transfer_suggestions' do
    ::Validators::AllowedStringQueryParams.validate(error:, params:)
    ::Services::InventoryTransferSuggestionsResponse.call(success:, error:, params:, request:)
  end
end
