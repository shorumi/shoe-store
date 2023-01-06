# frozen_string_literal: true

require_relative '../repositories/init'
require_relative '../representers/init'

module Services
  class InventoryJsonApiResponse
    def self.call(inventory_repo = ::Repositories::Inventory.new, logger = Logger.new($stdout), success:, error:, params:, request:)
      new(inventory_repo, logger, success, error, params, request).call
    end

    def call
      build_inventory_response
    end

    private

    attr_reader :inventory_repo, :logger, :success, :error, :params, :request

    def initialize(inventory_repo, logger, success, error, params, request)
      @inventory_repo = inventory_repo
      @logger = logger
      @success = success
      @error = error
      @params = params
      @request = request
    end

    def build_inventory_response
      inventories = inventory_repo.paginate(page:, per_page:, order:)
      response ||= inventory_representer(inventories)

      logger.info "Inventory response: #{response}"
      success.call(response)
    rescue StandardError => e
      logger.error("Request failed: #{e} - #{e.backtrace}")
      error.call('Unable to process request at this time, please try again later.')
    end

    def inventory_representer(collection)
      ::InventoryRepresenter.for_collection.new(collection).to_hash(
        user_options: { url: request.url },
        meta: {
          page:,
          per_page:,
          order:,
          total:
        }
      )
    end

    # TODO: Add a Pagination class to handle this logic in a near future.
    def order
      params.fetch(:order, 'desc').upcase
    end

    def page
      params.fetch(:page, 1)
    end

    def per_page
      params.fetch(:per_page, 10)
    end

    def total
      inventory_repo.all.count
    end
  end
end

