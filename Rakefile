# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

desc 'Load the environment'
task :environment do
  @env = ENV['RACK_ENV'] || 'development'
end

namespace ":whatever_name_space_name" do
  desc 'RAKE DESCRIPTION'
  task(rake_task_name: :environment) do
    # CODE COMES HERE!
  end
end
