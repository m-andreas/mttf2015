FactoryGirl.define do
  factory :job do
    status Job::OPEN
    route
    from
    to
    shuttle false
    car_brand "Mercedes"
    car_type "Sprinter"
    registration_number "w123456789"
    chassis_number ""
    mileage_collection 100
    mileage_delivery 200
    working_hours nil
    price_extern nil
    times_printed 0
    scheduled_collection_time nil
    scheduled_delivery_time nil
    actual_collection_time {DateTime.now}
    actual_delivery_time {DateTime.now + 2.hours}
  end
end