# frozen_string_literal: true

require 'support/spec_helper'
require './app/business/rules/quantity_alert'
require './app/repositories/inventory'

RSpec.describe Business::Rules::QuantityAlert do
  describe '#call' do
    context 'High inventory quantity' do
      before do
        FactoryBot.create(
          :inventory,
          sales_data: {
            id: SecureRandom.uuid,
            store: 'Ompa Loompa Store',
            model: 'Skater Shoes',
            inventory: (Business::Rules::QuantityAlert::QUANTITY_ALERTS['high'].max) * -1
          }
        )
      end

      it 'Publish a HIGH quantity alert message' do
        allow(::Workers::QuantityInventoryAlerts).to receive_message_chain(:set, :perform_later)

        expect(Business::Rules::QuantityAlert.call).to be_truthy
        expect(::Workers::QuantityInventoryAlerts.set(priority: 10)).to have_received(:perform_later).with(
          :alert_type => 'high_shoes_quantity',
          'inventory_quantity' => Business::Rules::QuantityAlert::QUANTITY_ALERTS['high'].max,
          'shoes_model' => 'Skater Shoes',
          'store' => 'Ompa Loompa Store'
        )
      end
    end

    context 'Low inventory quantity' do
      before do
        FactoryBot.create(
          :inventory,
          sales_data: {
            id: SecureRandom.uuid,
            store: 'Ompa Loompa Store',
            model: 'Skater Shoes',
            inventory: (Business::Rules::QuantityAlert::QUANTITY_ALERTS['low'].max) * -1
          }
        )
      end

      it 'Publish a LOW quantity alert message' do
        allow(::Workers::QuantityInventoryAlerts).to receive_message_chain(:set, :perform_later)

        expect(Business::Rules::QuantityAlert.call).to be_truthy
        expect(::Workers::QuantityInventoryAlerts.set(priority: 9)).to have_received(:perform_later).with(
          :alert_type => 'low_shoes_quantity',
          'inventory_quantity' => Business::Rules::QuantityAlert::QUANTITY_ALERTS['low'].max,
          'shoes_model' => 'Skater Shoes',
          'store' => 'Ompa Loompa Store'
        )
      end
    end

    context 'Out of Stock inventory quantity' do
      before do
        FactoryBot.create(
          :inventory,
          sales_data: {
            id: SecureRandom.uuid,
            store: 'Ompa Loompa Store',
            model: 'Skater Shoes',
            inventory: (Business::Rules::QuantityAlert::QUANTITY_ALERTS['out_of_stock'].max) * -1
          }
        )
      end

      it 'Publish a OUT OF STOCK quantity alert message' do
        allow(::Workers::QuantityInventoryAlerts).to receive_message_chain(:set, :perform_later)

        expect(Business::Rules::QuantityAlert.call).to be_truthy
        expect(::Workers::QuantityInventoryAlerts.set(priority: 9)).to have_received(:perform_later).with(
          :alert_type => 'out_of_stock',
          'inventory_quantity' => Business::Rules::QuantityAlert::QUANTITY_ALERTS['out_of_stock'].max,
          'shoes_model' => 'Skater Shoes',
          'store' => 'Ompa Loompa Store'
        )
      end
    end
  end
end

