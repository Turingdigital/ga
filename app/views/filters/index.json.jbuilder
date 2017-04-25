json.array!(@filters) do |filter|
  json.extract! filter, :id, :name
  json.url filter_url(filter, format: :json)
end
