# frozen_string_literal: true

require_relative '../../app/repositories/init'
require_relative '../validators/contracts/pagination_params'
require_relative '../errors/parameter_validation_error'

module Utils
  class Pagination
    PAGE_DEFAULT_SETTINGS = {
      page: 1,
      per_page: 10,
      order: 'DESC'
    }.freeze

    def self.paginate(params, collection:)
      new(params, collection).build_paginate
    end

    def build_paginate
      if !params.blank?
        validate_params.fmap do |validated_params|
          sanitized_params = sanitize_params(validated_params.to_h)
          return paginate_array(sanitized_params) if collection.is_a?(Array)

          return paginate_active_record(sanitized_params)
        end.or do |failed|
          logger.error("Failed to validate params: #{failed.errors.to_h}")

          raise Errors::ParameterValidationError.new(errors: failed.errors.to_h)
        end
      else
        collection.is_a?(Array) ? paginate_array(sanitize_params(params)) : paginate_active_record(sanitize_params(params))
      end
    end

    private

    attr_reader :params, :collection, :validator, :logger

    def initialize(params, collection, validator = ::Validators::Contracts::PaginationParams.new, logger = Logger.new($stdout))
      @params = params
      @collection = collection
      @validator = validator
      @logger = logger
    end

    def paginate_active_record(args)
      page = args[:page]
      per_page = args[:per_page]
      order = args[:order]

      page = page.to_i - 1 if page.to_i == 1
      offset = page.to_i * per_page.to_i

      ::Repositories.const_get(collection_klass_name).new.paginate(offset:, per_page:, order:)
    end

    def collection_klass_name
      collection.name.gsub("#{collection.module_parent}::", '')
    end

    def paginate_array(args)
      page = args[:page]
      per_page = args[:per_page]
      order = args[:order]

      arr = collection.sort_by { |item| item.dig(:attributes, :inventory_quantity) } # TODO: make this sort dynamic
      arr.reverse! if order == 'DESC'
      arr[((page - 1) * per_page)...(page * per_page)]
    end

    def validate_params
      validator.call(params).to_monad
    end

    def sanitize_params(args)
      {
        page: args.fetch(:page, PAGE_DEFAULT_SETTINGS[:page]).to_i,
        per_page: args.fetch(:per_page, PAGE_DEFAULT_SETTINGS[:per_page]).to_i,
        order: args.fetch(:order, PAGE_DEFAULT_SETTINGS[:order]).upcase
      }
    end
  end
end
