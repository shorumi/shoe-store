# frozen_string_literal: true

require_relative '../entities/inventory'

module Repositories
  class Inventory
    def initialize(model: ::Entities::Inventory)
      @model = model
    end

    def all
      model.all
    end

    def create(data:)
      model.create(sales_data: data)
    end

    def quantity_grouped_by_store_and_model_sql
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

    def paginate(page: 1, per_page: 10, order: 'desc')
      page = page.to_i - 1 if page.to_i == 1
      model.order(id: order.to_sym).limit(per_page.to_i).offset(page.to_i * per_page.to_i)
    end

    private

    attr_reader :model
  end
end