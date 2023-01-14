# frozen_string_literal: true

require_relative '../../repositories/init'
require_relative '../../workers/quantity_inventory_alerts'
require_relative '../../../libs/pub/messages/quantity_alert_message'

module Business
  module Rules
    class QuantityAlert
      QUANTITY_ALERTS = {
        'high' => -2999..0,
        'low' => -4800..-3000,
        'out_of_stock' => -6000..-4801
      }.freeze

      def self.call(inventory_repo = ::Repositories::Inventory.new, logger = Logger.new($stdout))
        new(inventory_repo, logger).call
      end

      def call
        perform_quantity_alerts
      end

      private

      attr_reader :inventory_repo, :logger

      def initialize(inventory_repo, logger)
        @inventory_repo = inventory_repo
        @logger = logger
      end

      def perform_quantity_alerts
        logger.info('Performing quantity alerts')
        if (inventory_items = inventory_repo.quantity_grouped_by_store_and_model)
          inventory_items.each do |row|
            quantity = row.fetch('inventory_quantity').to_i

            case quantity
            when QUANTITY_ALERTS['low']
              logger.info("Only #{quantity} shoes left for store: #{row['store']} and model: #{row['model']}")
              publish_alert ||= publish_alert(row.merge!(alert_type: 'low_shoes_quantity'))

              ::Workers::QuantityInventoryAlerts.set(priority: 9).perform_later(publish_alert)
            when QUANTITY_ALERTS['high']
              logger.info("A High number of #{quantity} shoes for store: #{row['store']} and model: #{row['model']}")
              publish_alert ||= publish_alert(row.merge!(alert_type: 'high_shoes_quantity'))

              ::Workers::QuantityInventoryAlerts.set(priority: 10).perform_later(publish_alert)
            when QUANTITY_ALERTS['out_of_stock']
              logger.info("Out of stock for store: #{row['store']} and model: #{row['model']}")
              publish_alert ||= publish_alert(row.merge!(alert_type: 'out_of_stock'))

              ::Workers::QuantityInventoryAlerts.set(priority: 11).perform_later(publish_alert)
            else
              next
            end
          end
        else
          logger.info('No inventory items found')
        end
      end

      def publish_alert(row)
        Pub::Messages::QuantityAlertMessage.call(row)
      end
    end
  end
end
