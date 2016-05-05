json.array!(@campaign_media) do |campaign_medium|
  json.extract! campaign_medium, :id, :medium
  json.url campaign_medium_url(campaign_medium, format: :json)
end
