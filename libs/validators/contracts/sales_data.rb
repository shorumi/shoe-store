require 'dry-validation'

Dry::Validation.load_extensions(:monads)

module Validators
  module Contracts
    class SalesData < Dry::Validation::Contract
      UUID_REGEX = /\A[\da-f]{8}-([\da-f]{4}-){3}[\da-f]{12}\z/i

      params do
        required(:id).filled(:string)
        required(:store).filled(:string)
        required(:model).filled(:string)
        required(:inventory).filled(:integer)
      end

      rule(:id) do
        key.failure('must be a valid uuid') unless value =~ UUID_REGEX
      end
    end
  end
end

