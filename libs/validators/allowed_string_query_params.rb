require_relative '../../app/services/parameters_error_response'

module Validators
  class AllowedStringQueryParams
    def self.validate(error:, params:)
      new(error, params).validate
    end

    def validate
      string_query_params_validation
    end

    private

    attr_reader :error, :params

    def initialize(error, params)
      @error = error
      @params = params
    end

    def string_query_params_validation
      exceptions = {}

      params.each_key do |key|
        next if Validators::Contracts::PaginationParams::ALLOWED_URI_QUERY.include?(key)

        exceptions[key] = 'is not allowed'
      end

      return unless exceptions.any?

      e = Errors::ParameterValidationError.new(errors: exceptions)
      ::Services::ParametersErrorResponse.call(error:, exception: e)
    end
  end
end
