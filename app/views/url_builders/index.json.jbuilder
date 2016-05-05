json.array!(@url_builders) do |url_builder|
  json.extract! url_builder, :id, :user_id, :url, :source, :medium, :term, :content, :name
  json.url url_builder_url(url_builder, format: :json)
end
