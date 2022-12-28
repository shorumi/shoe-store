# frozen_string_literal: true

require 'bundler/setup'
require 'sneakers/runner'
require 'logger'
require 'sneakers'
require 'sneakers/handlers/maxretry'

require 'active_job'
require 'advanced_sneakers_activejob'

require_relative '../app'

module Connection
  def self.sneakers
    @sneakers ||= Bunny.new(
      host: 'rabbitmq',
      vhost: '/',
      username: ENV['RABBITMQ_USER'],
      password: ENV['RABBITMQ_PWD'],
      automatically_recover: true,
      connection_timeout: 2,
      heartbeat: :server, # will use RabbitMQ setting
      continuation_timeout: ENV.fetch('BUNNY_CONTINUATION_TIMEOUT', 10_000).to_i
    )
  end
end

Sneakers.configure(
  connection: Connection.sneakers,
  exchange: 'sneakers',
  exchange_type: :direct,
  prefetch: 10,
  daemonize: false, # Send to background
  workers: `nproc`.to_i, # Number of per-cpu processes to run
  log: $stdout, # Log file
  pid_path: 'sneakers.pid', # Pid file
  timeout_job_after: 5.minutes, # Maximal seconds to wait for job
  # prefetch: ENV['SNEAKERS_PREFETCH'].to_i, # Grab 10 jobs together. Better speed.
  threads: 5, # Threadpool size (good to match prefetch)
  env: ENV['RACK_ENV'], # Environment
  durable: true, # Is queue durable?
  ack: true, # Must we acknowledge?
  heartbeat: 5, # Keep a good connection with broker
  handler: Sneakers::Handlers::Maxretry,
  retry_max_times: 10, # how many times to retry the failed worker process
  retry_timeout: 3 * 60 * 1000 # how long between each worker retry duration
)

Sneakers.logger.level = Logger::INFO

ActiveJob::Base.queue_adapter = :advanced_sneakers
