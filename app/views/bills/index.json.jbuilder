json.array!(@bills) do |bill|
  json.extract! bill, :id, :billed_at, :print_date
  json.url bill_url(bill, format: :json)
end
