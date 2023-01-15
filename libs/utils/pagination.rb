require_relative '../../libs/utils/pagination'
require_relative '../../app/repositories/init'

module Utils
  class Pagination
    PAGE_DEFAULT = {
      page: 1,
      per_page: 10,
      order: 'DESC'
    }.freeze

    def self.paginate(params, collection:)
      new(params, collection).paginate
    end

    def paginate
      case collection.is_a?(Array)
      when true
        paginate_array
      else
        paginate_active_record
      end
    end

    private

    attr_reader :params, :collection

    def initialize(params, collection)
      @params = params
      @collection = collection
    end

    def paginate_active_record
      page = page.to_i - 1 if page.to_i == 1
      offset = page.to_i * per_page.to_i

      ::Repositories.const_get(collection_klass_name).new.paginate(offset:, per_page:, order:)
    end

    def collection_klass_name
      collection.name.gsub("#{collection.module_parent}::", '')
    end

    def paginate_array
      arr = collection.sort_by { |item| item.dig(:attributes, :inventory_quantity) }
      arr.reverse! if order == 'DESC'
      arr[((page - 1) * per_page)...(page * per_page)]
    end

    def page
      params.fetch(:page, PAGE_DEFAULT[:page]).to_i
    end

    def per_page
      params.fetch(:per_page, PAGE_DEFAULT[:per_page]).to_i
    end

    def order
      params.fetch(:order, PAGE_DEFAULT[:order]).upcase
    end
  end
end
