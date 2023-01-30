require 'dry-validation'

Dry::Validation.load_extensions(:monads)

module Validators
  module Contracts
    class PaginationParams < Dry::Validation::Contract
      ALLOWED_URI_QUERY = %w[page per_page order].freeze

      params do
        optional(:page).filled(:integer)
        optional(:per_page).filled(:integer)
        optional(:order).filled(:string)
      end

      rule(:order) do
        key.failure('must be either "ASC" or "DESC"') if value.present? && ![:asc, :desc, :ASC, :DESC, 'asc', 'desc', 'ASC', 'DESC'].include?(value)
      end
    end
  end
end
