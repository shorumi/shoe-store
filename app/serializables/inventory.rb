require 'jsonapi/serializable'

module Serializables
  class Inventory < JSONAPI::Serializable::Resource
    type 'inventories'

    attributes :sales_data, :created_at, :updated_at
  end
end
