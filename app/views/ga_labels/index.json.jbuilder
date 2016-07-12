json.array!(@ga_labels) do |ga_label|
  json.extract! ga_label, :id, :name
  json.url ga_label_url(ga_label, format: :json)
end
