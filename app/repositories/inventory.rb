require_relative '../entities/inventory'

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

    def quantity_grouped_by_store_and_model_model_sql
      model.connection.execute(
        <<-SQL.squish
          SELECT (sales_data->>'store') AS store,
          (sales_data->>'model') AS model, SUM((sales_data->>'inventory')::numeric) AS inventory_quantity
          FROM inventories
          GROUP BY (sales_data->>'store'), (sales_data->>'model')
          ORDER BY inventory_quantity;
        SQL
      )
    end

    private

    attr_reader :model
  end
end