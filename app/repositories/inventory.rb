# frozen_string_literal: true

require_relative '../entities/init'
require_relative '../business/rules/init'

module Repositories
  class Inventory
    def initialize(model: ::Entities::Inventory)
      @model = model
    end

    def all
      model.all
    end

    def count
      model.count
    end

    def create(data:)
      model.create(sales_data: data)
    end

    def quantity_grouped_by_store_and_model
      execute_raw_query("#{sum_quantity_by_store_and_model};")
    end

    def paginate(offset:, per_page:, order:)
      model.order(id: order.to_sym).limit(per_page.to_i).offset(offset)
    end

    def inventory_transfer_suggestions
      execute_raw_query(inventory_transfer_suggestions_sql)
    end

    private

    attr_reader :model

    def sum_quantity_by_store_and_model_sql
      <<-SQL.squish
          SELECT
            (sales_data->>'store') AS store,
            (sales_data->>'model') AS shoes_model,
            SUM(-(sales_data->>'inventory')::integer) AS inventory_quantity
          FROM inventories
          GROUP BY store, shoes_model
          ORDER BY inventory_quantity
      SQL
    end

    def inventory_transfer_suggestions_sql
      <<~SQL.squish
        WITH inventory_by_store AS (#{sum_quantity_by_store_and_model_sql})
        SELECT
          store AS id,
          store AS from_store,
          shoes_model,
          inventory_quantity,
          (SELECT jsonb_agg(low_inventory) FROM (
            SELECT
              store,
              shoes_model,
              inventory_quantity
            FROM inventory_by_store
            WHERE inventory_quantity <= ANY(ARRAY#{Business::Rules::QuantityAlert::QUANTITY_ALERTS['low'].to_a}::integer[])
            AND shoes_model = ibs.shoes_model
          ) low_inventory) AS to_store
        FROM inventory_by_store AS ibs
        WHERE inventory_quantity >= ANY(ARRAY#{Business::Rules::QuantityAlert::QUANTITY_ALERTS['high'].to_a}::integer[])
      SQL
    end

    # This method is used to execute raw sql queries
    # And PG::BasicTypeMapForResults is used to convert the PG JSON_AGG result from String to Hash
    # Due to the fact ACTIVERECORD is not able to convert the JSON_AGG result from String to Hash
    def execute_raw_query(sql)
      model.connection.raw_connection.type_map_for_results = PG::BasicTypeMapForResults.new(model.connection.raw_connection)
      model.connection.execute(sql)
    end
  end
end
