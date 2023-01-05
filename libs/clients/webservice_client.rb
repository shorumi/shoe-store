require 'faye/websocket'
require 'eventmachine'
require 'json'

require_relative '../../bin/worker'
require_relative '../../app/workers/persist_shoe_sales_worker'

return unless ENV.fetch('SANDBOX_MODE', 'true') == 'false'

EM.run do
  logger ||= Logger.new($stdout)
  ws = Faye::WebSocket::Client.new("#{ENV.fetch('WEBSOCKET_URL')}:#{ENV.fetch('WEBSOCKET_PORT')}")

  ws.on :message do |event|
    if (data = JSON.parse(event.data))
      logger.info "Received: #{data}"
      ::PersistShoeSalesWorker.perform_later(data)
    end
  end
rescue StandardError => e
  logger.error("An unexpected Error occurred: #{e}")
end

