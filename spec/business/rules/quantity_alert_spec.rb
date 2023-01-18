# frozen_string_literal: true

require 'support/spec_helper'
require './app/business/rules/quantity_alert'
require './app/repositories/inventory'

RSpec.describe Business::Rules::QuantityAlert do
  RSpec.shared_examples 'quantity alert' do |alert_type, quantity, priority|
    let(:inventory_repo) { instance_double('Repositories::Inventory') }
    let(:logger) { instance_double('Logger') }
    let(:row) do
      {
        'store' => 'store',
        'model' => 'model',
        'inventory_quantity' => quantity
      }
    end

    before do
      allow(inventory_repo).to receive(:quantity_grouped_by_store_and_model).and_return([row])
      allow(logger).to receive(:info)
      allow(Workers::QuantityInventoryAlerts).to receive_message_chain(:set, :perform_later)
    end

    it 'publishes an alert message' do
      expect(Workers::QuantityInventoryAlerts.set(priority: priority)).to receive(:perform_later).with(
        row.merge('alert_type' => alert_type)
      )
      described_class.call(inventory_repo, logger)
    end
  end

  describe '#call' do
    context 'High inventory quantity' do
      it_behaves_like 'quantity alert', 'high_shoes_quantity', -100, 9
    end

    context 'Low inventory quantity' do
      it_behaves_like 'quantity alert', 'low_shoes_quantity', -300, 10
    end

    context 'Out of Stock inventory quantity' do
      it_behaves_like 'quantity alert', 'out_of_stock', -500, 11
    end
  end
end
