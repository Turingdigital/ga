class UrlBuilder < ActiveRecord::Base
  belongs_to :user

  # has_many :url_builder_campaign_mediumships
  # has_many :campaign_media, :through => :url_builder_campaign_mediumships
  belongs_to :campaign_medium

  # def url_shouter
  #   result = `curl https://www.googleapis.com/urlshortener/v1/url\?key\=#{ENV["GOOGLE_API_KEY"]} -H 'Content-Type: application/json' -d '{"longUrl": "http://www.adup.com/"}'`
  # end

  def short_url
    result = `curl https://www.googleapis.com/urlshortener/v1/url\?key\=#{ENV["GOOGLE_API_KEY"]} -H 'Content-Type: application/json' -d '{"longUrl": "#{builded_url}"}'`
    return JSON.parse(result)["id"]
  end

  def builded_url
    result = url
    result += result.include?('?') ? '&' : '?'
    result += "utm_source=#{source}" if source # 必填
    # result += "&utm_medium=#{campaign_medium}" if campaign_medium # 必填
    result += "&utm_term=#{term}" if term
    result += "&utm_content=#{content}" if content
    result += "&utm_name=#{name}" if name # 必填
    return result
  end
end
