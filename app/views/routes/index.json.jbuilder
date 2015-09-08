json.array!(@routes) do |route|
  json.extract! route, :id, :from_id, :to_id, :calculation_basis, :distance, :status
  json.url route_url(route, format: :json)
end
