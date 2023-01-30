# frozen_string_literal: true

require 'jsonapi/serializable/renderer'

require_relative '../repositories/init'
require_relative '../serializables/init'
require_relative '../entities/init'
require_relative '../../libs/utils/pagination'
require_relative 'parameters_error_response'


module Services
  class InventoryResponse
    def self.call(
      inventory_repo = ::Repositories::Inventory.new,
      logger = Logger.new($stdout),
      renderer = JSONAPI::Serializable::Renderer.new,
      success:,
      error:,
      params:,
      request:
    )
      new(inventory_repo, logger, renderer, success, error, params, request).call
    end

    def call
      build_inventory_response
    end

    private

    attr_reader :inventory_repo, :logger, :renderer, :success, :error, :params, :request

    def initialize(inventory_repo, logger, renderer, success, error, params, request)
      @inventory_repo = inventory_repo
      @logger = logger
      @renderer = renderer
      @success = success
      @error = error
      @params = params
      @request = request
    end

    def build_inventory_response
      paginated_inventory_items ||= ::Utils::Pagination.paginate(params, collection: Entities::Inventory)

      response ||= renderer.render(
        paginated_inventory_items,
        class: {
          'Entities::Inventory': ::Serializables::Inventory
        },
        meta: {
          page: params.fetch(:page, Utils::Pagination::PAGE_DEFAULT_SETTINGS[:page]).to_i,
          per_page: params.fetch(:per_page, Utils::Pagination::PAGE_DEFAULT_SETTINGS[:per_page]).to_i,
          order: params.fetch(:order, Utils::Pagination::PAGE_DEFAULT_SETTINGS[:order]),
          total: inventory_repo.count
        }
      )

      logger.info "Inventory response: #{response}"
      success.call(response)
    rescue ::Errors::ParameterValidationError => e
      ::Services::ParametersErrorResponse.call(error:, exception: e)
    rescue StandardError => e
      logger.error("Request failed: #{e} - #{e.backtrace}")
      error.call('Unable to process request at this time, please try again later.')
    end
  end
end
