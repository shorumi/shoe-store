# frozen_string_literal: true

require 'sinatra/json'
require 'sinatra/reloader'
require 'sneakers'

require_relative '../services/shoe_sales_webservice'
require_relative '../entities/init'
require_relative '../repositories/init'
require_relative '../business/rules/init'
require_relative '../custom/exception_messages/init'

class ShoeStoreApi < Sinatra::Application
  def initialize(app = nil, shoe_sales_webservice: ::Services::ShoeSalesWebservice)
    super(app)
    @shoe_sales_webservice = shoe_sales_webservice
  end

  configure :development do
    register Sinatra::Reloader
  end

  # ACTION METHODS COME HERE
  get '/shoe_sales' do
    status 200
  end

  private

  attr_reader :shoe_sales_webservice
end
