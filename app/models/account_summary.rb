class AccountSummary < ActiveRecord::Base
  belongs_to :user

  def hash
    return JSON.parse self.jsonString
  end

  class << self
    def fetch user
      analytics = Analytics.new user
      result = analytics.accountSummaries
      self.create(user: user, jsonString: result.to_json) if result
    end
  end
end

result = `curl https://www.googleapis.com/urlshortener/v1/url\?key\=#{ENV["GOOGLE_API_KEY"]} -H 'Content-Type: application/json' -d '{"longUrl": "http://www.google.com/"}'`
