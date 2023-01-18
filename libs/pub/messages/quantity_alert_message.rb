# frozen_string_literal: true

module Pub
  module Messages
    class QuantityAlertMessage
      class << self
        def call(row)
          @row = row
        end

        private

        attr_reader :row

        def build_message(row)
          {
            store: row.fetch('store'),
            model: row.fetch('model'),
            quantity: row.fetch('inventory_quantity'),
            alert_type: row.fetch('alert_type')
          }.to_json
        end
      end
    end
  end
end
