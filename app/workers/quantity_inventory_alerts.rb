# frozen_string_literal: true

require 'bundler/setup'
require 'active_job'
require 'sneakers'

module Workers
  class QuantityInventoryAlerts < ActiveJob::Base
    queue_as :quantity_alerts

    def perform(message)
      logger.debug("delivery_info: #{delivery_info}, headers: #{headers}, message: #{message}")
    end
  end
end
