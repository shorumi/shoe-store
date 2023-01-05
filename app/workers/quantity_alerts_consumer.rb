require 'sneakers'

module Workers
  class QuantityAlertsConsumer
    include Sneakers::Worker
    from_queue 'quantity_alerts'

    def work(message)
      logger.debug("Consuming message: #{message}")
      logger.error("Unable to process the following message: #{message}") if message.include?('fail')

      ack!
    rescue StandardError => e
      logger.error("An unexpected Error occurred: #{e}")
      reject!
    end

    private

    def logger
      @logger ||= Logger.new($stdout)
    end
  end
end
