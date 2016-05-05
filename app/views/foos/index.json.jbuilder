json.array!(@foos) do |foo|
  json.extract! foo, :id, :title, :start_date
  json.url foo_url(foo, format: :json)
end
