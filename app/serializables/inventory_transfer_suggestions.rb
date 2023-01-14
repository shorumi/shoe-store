require 'jsonapi/serializable'

module Serializables
  class InventoryTransferSuggestions < JSONAPI::Serializable::Resource
    type 'inventory_transfer_suggestions'

    id do
      @object['id']
    end

    attribute :from_store do
      @object['from_store']
    end

    attribute :shoes_model do
      @object['shoes_model']
    end

    attribute :inventory_quantity do
      @object['inventory_quantity']
    end

    attribute :to_store do
      @object['to_store']
    end
  end
end
