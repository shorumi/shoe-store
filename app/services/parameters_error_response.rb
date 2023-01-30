# frozen_string_literal: true

require 'jsonapi/serializable/renderer'

module Services
  class ParametersErrorResponse
    def self.call(logger = Logger.new($stdout), renderer = JSONAPI::Serializable::Renderer.new, error:, exception:)
      new(logger, renderer, error, exception).call
    end

    def call
      build_parameter_error_response
    end

    private

    attr_reader :logger, :renderer, :error, :exception

    def initialize(logger, renderer, error, exception)
      @logger = logger
      @renderer = renderer
      @error = error
      @exception = exception
    end

    def build_parameter_error_response
      logger.error("An issue occurred while validating parameters, exception: exception: #{exception}")

      klass = Class.new(JSONAPI::Serializable::Error) do
        status { @object[:status] }
        source do
          parameter @object[:source][:parameter]
        end
        title { @object[:title] }
        detail { @object[:detail] }
      end

      error_response = renderer.render_errors(exception.serializable_hash, class: { Hash: klass })
      error.call(error_response)
    rescue StandardError => e
      logger.error("Request failed: #{e} - #{e.backtrace}")
      error.call('Unable to process request at this time, please try again later.')
    end
  end
end
