class UrlBuilder < ActiveRecord::Base
  belongs_to :user

  has_many :url_builder_campaign_mediumships
  has_many :campaign_media, :through => :url_builder_campaign_mediumships

  def url_shouter
    result = `curl https://www.googleapis.com/urlshortener/v1/url\?key\=#{ENV["GOOGLE_API_KEY"]} -H 'Content-Type: application/json' -d '{"longUrl": "http://www.adup.com/"}'`
  end
end
