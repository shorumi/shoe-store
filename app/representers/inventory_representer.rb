require 'roar/json/json_api'

class InventoryRepresenter < Roar::Decorator
  include Roar::JSON::JSONAPI.resource :inventories

  common_link = lambda { |opts|
    parsed_url = URI.parse(opts[:url])
    "#{parsed_url.scheme}://#{parsed_url.host}:#{parsed_url.port}#{parsed_url.path}"
  }

  # top-level link.
  link :self, toplevel: true do |opts|
    common_link.call(opts)
  end

  # resource object links
  link :self do |opts|
    "#{common_link.call(opts)}/#{represented.id}"
  end

  # resource object attributes
  attributes do
    property :sales_data
    property :created_at
    property :updated_at
  end
end
