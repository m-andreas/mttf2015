json.array!(@companies) do |company|
  json.extract! company, :id, :name, :address, :city, :zip_code, :country, :telephone, :email, :price_per_km, :price_flat_rate
  json.url company_url(company, format: :json)
end
