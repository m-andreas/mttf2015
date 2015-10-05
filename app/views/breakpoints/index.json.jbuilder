json.array!(@breakpoints) do |breakpoint|
  json.extract! breakpoint, :id, :position, :job_id, :distance
  json.url breakpoint_url(breakpoint, format: :json)
end
