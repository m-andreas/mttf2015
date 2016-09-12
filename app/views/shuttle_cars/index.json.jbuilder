json.array!(@shuttle_cars) do |shuttle_car|
  json.extract! shuttle_car, :id, :car_brand, :car_type, :registration_number
  json.url shuttle_car_url(shuttle_car, format: :json)
end
