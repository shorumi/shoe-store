# frozen_string_literal: true

require_relative '../../repositories/init'
require_relative '../../workers/quantity_inventory_alerts'
require_relative '../../../libs/pub/messages/quantity_alert_message'

module Business
  module Rules
    class QuantityAlert
      QUANTITY_ALERTS = {
        'high' => -200..0,
        'low' => -480..-201,
        'out_of_stock' => -600..-481
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
            when QUANTITY_ALERTS['high']
              logger.info("A High number of #{quantity} shoes for store: #{row['store']} and model: #{row['model']}")
              publish_alert_message = build_publish_alert_message(row.merge!('alert_type' => 'high_shoes_quantity'))

              enqueue_alerts(publish_alert_message, priority: 9)
            when QUANTITY_ALERTS['low']
              logger.info("Only #{quantity} shoes left for store: #{row['store']} and model: #{row['model']}")
              publish_alert_message = build_publish_alert_message(row.merge!('alert_type' => 'low_shoes_quantity'))

              enqueue_alerts(publish_alert_message, priority: 10)
            when QUANTITY_ALERTS['out_of_stock']
              logger.info("Out of stock for store: #{row['store']} and model: #{row['model']}")
              publish_alert_message ||= build_publish_alert_message(row.merge!('alert_type' => 'out_of_stock'))

              enqueue_alerts(publish_alert_message, priority: 11)
            else
              next
            end
          end
        else
          logger.info('No inventory items found')
        end
      end

      def build_publish_alert_message(row)
        Pub::Messages::QuantityAlertMessage.call(row)
      end

      def enqueue_alerts(publish_alert_message, priority:)
        ::Workers::QuantityInventoryAlerts.set(priority:).perform_later(publish_alert_message)
      end
    end
  end
end
