class Inventory < ActiveRecord::Migration[7.0]
  def change
    execute <<-SQL
      CREATE TABLE inventories (
        id SERIAL PRIMARY KEY NOT NULL,
        sales_data JSONB NOT NULL DEFAULT '{}',
        created_at TIMESTAMP NOT NULL,
        updated_at TIMESTAMP NOT NULL,

        CONSTRAINT validate_id CHECK (length(sales_data->>'id') > 0 AND (sales_data->>'id') IS NOT NULL),
        CONSTRAINT validate_store CHECK (length(sales_data->>'store') > 0 AND (sales_data->>'store') IS NOT NULL),
        CONSTRAINT validate_model CHECK (length(sales_data->>'model') > 0 AND (sales_data->>'model') IS NOT NULL),
        CONSTRAINT validate_inventory CHECK ((sales_data->>'inventory')::integer >= 0 AND (sales_data->>'inventory') IS NOT NULL)
      );

      CREATE INDEX sales_data_index ON inventories USING gin (sales_data);
    SQL
  end
end
