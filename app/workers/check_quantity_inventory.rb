module Workers
  class CheckQuantityInventory < ActiveJob::Base
    queue_as :quantity_alerts

    def perform
      # Do something
    end
  end
end