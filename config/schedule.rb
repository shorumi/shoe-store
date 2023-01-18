# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'rake'

require_relative '../app/business/rules/init'
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

rack_env = ENV['APP_ENV'] ||= 'production'
set :output, error: 'log/crontab_error.log', standard: 'log/crontab.log'
set :environment, rack_env
ENV.each { |k, v| env(k, v) }

every 2.minutes do
  rake 'whenever:handle_quantity_alerts_task'
end