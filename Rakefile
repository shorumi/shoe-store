# frozen_string_literal: true

require 'rubygems'
require 'sneakers/tasks'
require 'sinatra/activerecord/rake'
require 'bundler/setup'

require './bin/worker'

desc 'Load the environment'
task :environment do
  @env = ENV['RACK_ENV'] || 'development'
end

namespace :whenever do
  desc 'Handle Quantity Alerts for inventory'
  task(handle_quantity_alerts_task: :environment) do
    ::Business::Rules::QuantityAlert.call
  end
end
