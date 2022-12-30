# frozen_string_literal: true

require 'sinatra/json'
require 'sinatra/reloader'
require 'sneakers'

require_relative '../business/rules/init'

class ShoeStoreApi < Sinatra::Application
  def initialize(app = nil)
    super(app)
  end

  configure :development do
    register Sinatra::Reloader
  end

  # ACTION METHODS COME HERE
  get '/shoe_sales' do
    ::Business::Rules::QuantityAlert.call

    status 200
  end

  private

  attr_reader :shoe_sales_webservice
end
