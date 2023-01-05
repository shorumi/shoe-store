# frozen_string_literal: true

require_relative '../../repositories/init'
require_relative '../../workers/quantity_inventory_alerts'
require_relative '../../../libs/pub/messages/quantity_alert_message'

module Business
  module Rules
    class QuantityAlert
      QUANTITY_ALERTS = {
        'nothing' => 0,
        'low' => 10..50,
        'high' => 200..400
      }.freeze

      def self.call(repo = ::Repositories::Inventory.new)
        new(repo).call
      end

      def call
        perform_quantity_alerts
      end

      private

      attr_reader :repo

      def initialize(repo)
        @repo = repo
      end

      def perform_quantity_alerts
        logger.info('Performing quantity alerts')
        if (inventory_items = repo.quantity_grouped_by_store_and_model_model_sql)
          inventory_items.each do |row|
            quantity = row.fetch('inventory_quantity').to_i

            case quantity
            when QUANTITY_ALERTS['nothing']
              logger.info("No more shoes for store: #{row['store_id']} and model: #{row['model_id']}")
              publish_alert ||= publish_alert(row.merge!(alert_type: 'no_more_shoes'))

              ::Workers::QuantityInventoryAlerts.set(priority: 10).perform_later(publish_alert)
            when QUANTITY_ALERTS['low']
              logger.info("Only #{quantity} shoes left for store: #{row['store']} and model: #{row['model']}")
              publish_alert ||= publish_alert(row.merge!(alert_type: 'low_shoes_quantity'))

              ::Workers::QuantityInventoryAlerts.set(priority: 9).perform_later(publish_alert)
            when QUANTITY_ALERTS['high']
              logger.info("A High number of #{quantity} shoes for store: #{row['store']} and model: #{row['model']}")
              publish_alert ||= publish_alert(row.merge!(alert_type: 'high_shoes_quantity'))

              ::Workers::QuantityInventoryAlerts.set(priority: 10).perform_later(publish_alert)
            else
              next
            end
          end
        else
          logger.info('No inventory items found')
        end
      end

      def logger
        @logger ||= Logger.new($stdout)
      end

      def publish_alert(row)
        Pub::Messages::QuantityAlertMessage.call(row)
      end
    end
  end
end
