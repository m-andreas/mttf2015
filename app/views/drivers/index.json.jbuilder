json.array!(@drivers) do |driver|
  json.extract! driver, :id, :first_name, :last_name, :entry_date, :exit_date, :date_of_birth, :place_of_birth, :address, :city, :zip_code, :telepone, :telephone2, :licence_number, :issuing_authority, :driving_licence_category, :comment, :social_security_number, :driving_licence_copy, :registration_copy, :service_contract
  json.url driver_url(driver, format: :json)
end
