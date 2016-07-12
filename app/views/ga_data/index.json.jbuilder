json.array!(@ga_data) do |ga_datum|
  json.extract! ga_datum, :id, :ga_label_id, :profile, :json
  json.url ga_datum_url(ga_datum, format: :json)
end
