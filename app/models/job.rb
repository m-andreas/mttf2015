class Job < ActiveRecord::Base
  serialize :driver_ids
  belongs_to :from, foreign_key: :from_id, class_name: "Address"
  belongs_to :to, foreign_key: :to_id, class_name: "Address"

  def driver
    driver_ids.first
  end

  def co_drivers
    co_drivers = driver_ids
    co_drivers.delete_at 0
    return co_drivers
  end
end
