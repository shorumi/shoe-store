# frozen_string_literal: true

require 'support/spec_helper'

RSpec.describe app do
  let!(:inventory) { FactoryBot.create(:inventory) }
  let(:attributes) { JSON.parse(last_response.body) }
  let(:expected_inventory_attributes) do
    {
      'data' => [
        {
          'id' => inventory.id.to_s,
          'type' => 'inventories',
          'attributes' => {
            'sales_data' => {
              'id' => inventory.sales_data['id'],
              'model' => inventory.sales_data['model'],
              'store' => inventory.sales_data['store'],
              'inventory' => inventory.sales_data['inventory'],
            },
            'created_at' => include(inventory.created_at.strftime('%Y-%m-%d')),
            'updated_at' => include(inventory.updated_at.strftime('%Y-%m-%d')),
          }
        }
      ],
      'meta' => {
        'page' => 1,
        'per_page' => 10,
        'order' => 'DESC',
        'total' => 1
      }
    }
  end

  describe 'JSONAPI format' do
    let(:page) { 1 }
    let(:per_page) { 10 }
    let(:order) { 'DESC' }

    describe 'GET /inventories' do
      it 'should return inventories resources' do
        get '/inventories'

        expect(last_response).to be_ok
        expect(attributes).to include(expected_inventory_attributes)
      end

      context 'when page is specified' do
        let!(:inventories) { FactoryBot.create_list(:inventory, 11) }
        let(:page) { 1 }
        let(:per_page) { 5 }
        let(:order) { 'ASC' }

        it 'should return only 5 inventories resources per page' do
          get "/inventories?page=#{page}&per_page=#{per_page}&order=#{order}"

          expect(last_response).to be_ok
          expect(attributes['data'].count).to eq(5)
        end
      end
    end

    describe 'GET /inventories/transfer_suggestions' do
      let!(:inventory_transfer_suggestions) do
        ::Business::Rules::QuantityAlert::QUANTITY_ALERTS.map do |_, range|
          FactoryBot.create(
            :inventory,
            sales_data: {
              'id' => SecureRandom.uuid,
              'store' => "store_#{range.min}",
              'model' => 'model',
              'inventory' => range.max * -1
            }
          )
        end
      end
      let(:expected_inventory_transfer_suggestions_attrs) do
        {
          'data' => [
            {
              'id' => inventory_transfer_suggestions.first.sales_data['store'],
              'type' => 'inventory_transfer_suggestions',
              'attributes' => {
                'from_store' => inventory_transfer_suggestions.first.sales_data['store'],
                'shoes_model' => inventory_transfer_suggestions.first.sales_data['model'],
                'inventory_quantity' => inventory_transfer_suggestions.first.sales_data['inventory'] * -1,
                'to_store' => [
                  {
                    'store' => inventory_transfer_suggestions.third.sales_data['store'],
                    'shoes_model' => inventory_transfer_suggestions.third.sales_data['model'],
                    'inventory_quantity' => inventory_transfer_suggestions.third.sales_data['inventory'] * -1
                  },
                  {
                    'store' => inventory_transfer_suggestions.second.sales_data['store'],
                    'shoes_model' => inventory_transfer_suggestions.second.sales_data['model'],
                    'inventory_quantity' => inventory_transfer_suggestions.second.sales_data['inventory'] * -1
                  }
                ]
              }
            }
          ],
          'meta' => {
            'page' => page,
            'per_page' => per_page,
            'order' => order,
            'total' => 1
          }
        }
      end

      it 'should return inventories transfer suggestions' do
        get '/inventories/transfer_suggestions'

        expect(last_response).to be_ok
        expect(attributes).to include(expected_inventory_transfer_suggestions_attrs)
      end

      context 'when paginating inventories transfer suggestions' do
        let(:per_page) { 1 }

        it 'should return only 1 inventory transfer suggestion' do
          get "/inventories/transfer_suggestions?page=#{page}&per_page=#{per_page}&order=#{order}"

          expect(last_response).to be_ok
          expect(attributes).to include(expected_inventory_transfer_suggestions_attrs)
        end
      end

      context 'when paginating inventories transfer suggestions in different orders' do
        let!(:inventory_transfer_suggestions) do
          ::Business::Rules::QuantityAlert::QUANTITY_ALERTS.each do |_, range|
            FactoryBot.create_list(:inventory, 200) do |inventory, i|
              inventory.sales_data = {
                'id' => SecureRandom.uuid,
                'store' => "store_#{range.min}",
                'model' => "model_#{i}",
                'inventory' => i * [1, 2, 3, 4, 5, 10, 20, 30, 40, 50].sample
              }
              inventory.save!
            end
          end
        end


        context 'when in ASC order' do
          let(:order) { 'ASC' }

          it 'should return inventories transfer suggestions in ASC order' do
            get "/inventories/transfer_suggestions?page=#{page}&per_page=#{per_page}&order=#{order}"

            expect(last_response).to be_ok
            attributes['data'].each_with_index do |data, index|
              if attributes['data'][index + 1]
                expect(data['attributes']['inventory_quantity']).to be <= attributes['data'][index + 1]['attributes']['inventory_quantity']
              end
            end
          end
        end

        context 'when in DESC order' do
          let(:order) { 'DESC' }

          it 'should return inventories transfer suggestions in DESC order' do
            get "/inventories/transfer_suggestions?page=#{page}&per_page=#{per_page}&order=#{order}"

            expect(last_response).to be_ok
            attributes['data'].each_with_index do |data, index|
              if attributes['data'][index + 1]
                expect(data['attributes']['inventory_quantity']).to be >= attributes['data'][index + 1]['attributes']['inventory_quantity']
              end
            end
          end
        end
      end

      context 'when there is no inventory transfer suggestions' do
        let!(:inventory_transfer_suggestions) { [] }
        let(:expected_inventory_transfer_suggestions_attrs) do
          {
            'data' => nil,
            'meta' => {
              'page' => page,
              'per_page' => per_page,
              'order' => order,
              'total' => 0
            }
          }
        end

        it 'should return the data attribute with an empty array' do
          get '/inventories/transfer_suggestions'

          expect(last_response).to be_ok
          expect(attributes).to include(expected_inventory_transfer_suggestions_attrs)
        end
      end

      context 'when there is no store to transfer the shoes to' do
        let!(:inventory_transfer_suggestions) do
          FactoryBot.create(
            :inventory,
            sales_data: {
              'id' => SecureRandom.uuid,
              'store' => 'store_1',
              'model' => 'model',
              'inventory' => 0
            }
          )
        end
        let(:expected_inventory_transfer_suggestions_attrs) do
          {
            'data' => [
              {
                'id' => inventory_transfer_suggestions.sales_data['store'],
                'type' => 'inventory_transfer_suggestions',
                'attributes' => {
                  'from_store' => inventory_transfer_suggestions.sales_data['store'],
                  'shoes_model' => inventory_transfer_suggestions.sales_data['model'],
                  'inventory_quantity' => inventory_transfer_suggestions.sales_data['inventory'],
                  'to_store' => 'There is no store to transfer the shoes to'
                }
              }
            ],
            'meta' => {
              'page' => page,
              'per_page' => per_page,
              'order' => order,
              'total' => 1
            }
          }
        end

        it 'should return the to_store attribute with a messaging saying that there are no stores needing shoe transfers' do
          get '/inventories/transfer_suggestions'

          expect(last_response).to be_ok
          expect(attributes).to include(expected_inventory_transfer_suggestions_attrs)
        end
      end
    end
  end
end
