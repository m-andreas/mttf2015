json.array!(@jobs) do |job|
  json.extract! job, :id, :driver_ids, :cost_center_id, :finished, :created_by_id, :route_id, :from_id, :to_id, :shuttle
  json.url job_url(job, format: :json)
end
