require_relative '../entities/inventory.rb'

module Repositories
  class Inventory
    def initialize(model: ::Entities::Inventory)
      @model = model
    end

    def create(data:)
      model.create(sales_data: data)
    end

    def all
      model.all
    end

    private

    attr_reader :model
  end
end