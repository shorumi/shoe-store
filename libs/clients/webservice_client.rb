require 'faye/websocket'
require 'eventmachine'
require 'json'

require_relative '../../bin/worker'
require_relative '../../app/workers/persist_shoe_sales_worker'
require_relative '../../libs/validators/contracts/sales_data_contract'

EM.run do
  logger ||= Logger.new($stdout)
  ws = Faye::WebSocket::Client.new("#{ENV.fetch('WEBSOCKET_URL')}:#{ENV.fetch('WEBSOCKET_PORT')}")

  ws.on :message do |event|
    if (data = JSON.parse(event.data))
      logger.info "Received: #{data}"
      logger.info("Validating expected data contract")
      SalesDataContract.new.call(data).to_monad
        .fmap do |validated_data|
          logger.info("Validated data: #{validated_data.to_h}")
          PersistShoeSalesWorker.perform_later(validated_data.to_h)
        end
        .or do |failed|
          logger.error("Failed to validate data: #{failed.errors.to_h}")
        end
    end
  end
rescue StandardError => e
  logger.error("An unexpected Error occurred: #{e}")
end
