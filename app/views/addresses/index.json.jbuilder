json.array!(@addresses) do |address|
  json.extract! address, :id, :created_by, :country, :city, :zip_code, :address, :address_short, :inactive
  json.url address_url(address, format: :json)
end
