require 'jsonapi/serializable/renderer'

class ApplicationController < Sinatra::Application
  configure :development do
    register Sinatra::Reloader
  end

  set :default_content, 'application/vnd.api+json'

  private

  def success
    lambda { |response|
      body json(response)
      status 200
    }
  end

  def error
    lambda { |response|
      body json(response)

      halt 400
    }
  end
end
