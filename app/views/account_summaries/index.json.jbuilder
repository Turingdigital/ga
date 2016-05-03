json.array!(@account_summaries) do |account_summary|
  json.extract! account_summary, :id, :user_id, :jsonString
  json.url account_summary_url(account_summary, format: :json)
end
