# frozen_string_literal: true
require 'jsonapi/serializable/renderer'

require_relative '../entities/init'
require_relative '../repositories/init'
require_relative '../serializables/init'
require_relative '../../libs/utils/pagination'

module Services
  class InventoryTransferSuggestionsResponse
    def self.call(
      inventory_repo = ::Repositories::Inventory.new,
      renderer = JSONAPI::Serializable::Renderer.new,
      logger = Logger.new($stdout),
      success:,
      error:,
      params:,
      request:
    )
      new(inventory_repo, logger, renderer, success:, error:, params:, request:).call
    end

    def call
      build_inventory_transfer_suggestions_response
    end

    private

    attr_reader :inventory_repo, :logger, :renderer, :success, :error, :params, :request

    def initialize(inventory_repo, logger, renderer, success:, error:, params:, request:)
      @inventory_repo = inventory_repo
      @logger = logger
      @renderer = renderer
      @success = success
      @error = error
      @params = params
      @request = request
    end

    def build_inventory_transfer_suggestions_response
      inventory_transfer_suggestions ||= inventory_repo.inventory_transfer_suggestions.to_a
      paginated_inventory_transfer_suggestions ||= ::Utils::Pagination.paginate(params, collection: inventory_transfer_suggestions)

      response = renderer.render(
        paginated_inventory_transfer_suggestions,
        class: {
          Hash: ::Serializables::InventoryTransferSuggestions
        },
        meta: {
          page: params.fetch(:page, Utils::Pagination::PAGE_DEFAULT_SETTINGS[:page]).to_i,
          per_page: params.fetch(:per_page, Utils::Pagination::PAGE_DEFAULT_SETTINGS[:per_page]).to_i,
          order: params.fetch(:order, Utils::Pagination::PAGE_DEFAULT_SETTINGS[:order]),
          total: inventory_transfer_suggestions.count
        }
      )

      logger.info "Inventory transfer suggestions response: #{response}"
      success.call(response)
    rescue StandardError => e
      logger.error("Request failed: #{e} - #{e.backtrace}")
      error.call('Unable to process request at this time, please try again later.')
    end
  end
end
