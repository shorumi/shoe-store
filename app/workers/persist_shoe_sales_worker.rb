# frozen_string_literal: true

require 'bundler/setup'
require 'active_job'
require 'sneakers'

require_relative '../repositories/init'

class PersistShoeSalesWorker < ActiveJob::Base
  queue_as :job_queue

  def perform(sale_data)
    logger.debug("Persisting sale data: #{sale_data}, delivery_info: #{delivery_info}, headers: #{headers}")
    inventory_repo.transaction do
      if inventory_repo.create(data: sale_data)
        logger.info("Successfully created inventory: #{sale_data}")
        raise ActiveRecord::Rollback if %w[TRUE true].include?(ENV.fetch('SANDBOX_MODE', 'true'))
      else
        logger.error('Failed to create inventory')
      end
    end
  rescue StandardError => e
    logger.error("An unexpected Error occurred: #{e}")
  end

  private

  def logger
    @logger ||= Logger.new($stdout)
  end

  def inventory_repo
    @inventory_repo ||= ::Repositories::Inventory.new
  end
end
