class Route < ActiveRecord::Base
  belongs_to :from, foreign_key: :from_id, class_name: "Address"
  belongs_to :to, foreign_key: :to_id, class_name: "Address"
  paginates_per 10

  NEW = 0
  PROCESSED = 1
  DELETED = 2

  def self.find_or_create( from_id, to_id)
    route = find_by( from_id: from_id, to_id: to_id )
    if route.nil?
      route = Route.create(
        from_id: from_id,
        to_id: to_id
      )

    end
    return route.id
  end
end
