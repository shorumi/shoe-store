# frozen_string_literal: true

require 'sinatra/activerecord'

module Entities
  class Inventory < ActiveRecord::Base
    self.table_name = 'inventories'
  end
end
