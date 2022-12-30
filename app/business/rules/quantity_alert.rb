require_relative '../../repositories/init'

module Business
  module Rules
    class QuantityAlert
      class << self
        def call
          catch_quantity_alerts
        end

        private

        def catch_quantity_alerts
          Repositories::Inventory.new.quantity_grouped_by_store_and_model_model_sql.each do |row|
            case row['quantity']
            when 0
              puts "No more shoes for #{row['model']} at #{row['store']}"
            when 100
              puts "Shoes quantity is too LOW: #{row['quantity']} qty for #{row['model']} at #{row['store']}"
            when 1000
              puts "Shoes quantity is too HIGH: #{row['quantity']} qty for #{row['model']} at #{row['store']}"
            else
              next
            end
          end
        end
      end
    end
  end
end
