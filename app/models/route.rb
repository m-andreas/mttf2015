class Route < ActiveRecord::Base
  belongs_to :from, foreign_key: :from_id, class_name: "Address"
  belongs_to :to, foreign_key: :to_id, class_name: "Address"

  NEW = 0
  PROCESSED = 1
  DELETED = 2

end
