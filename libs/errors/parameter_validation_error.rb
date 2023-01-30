# frozen_string_literal: true
require_relative 'standard_error'

module Errors
  class ParameterValidationError < ::Errors::StandardError
    def initialize(errors:)
      @errors = errors
      @status = 400
      @title = 'Parameter validation error'
    end

    def serializable_hash
      errors.reduce([]) do |r, (att, msg)|
        r << {
          status:,
          title:,
          detail: msg,
          source: { parameter: att }
        }
      end
    end

    private

    attr_reader :errors
  end
end
