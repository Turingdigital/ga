require 'open-uri'

class UrlBuilder < ActiveRecord::Base
  belongs_to :user

  # has_many :url_builder_campaign_mediumships
  # has_many :campaign_media, :through => :url_builder_campaign_mediumships
  has_many :url_analytics
  belongs_to :campaign_medium

  # def url_shouter
  #   result = `curl https://www.googleapis.com/urlshortener/v1/url\?key\=#{ENV["GOOGLE_API_KEY"]} -H 'Content-Type: application/json' -d '{"longUrl": "http://www.adup.com/"}'`
  # end

  before_save :set_short_url

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      ccn = csv_column_names
      csv << ccn #column_names
      ccn.delete("campaign_medium")
      all.each do |product|
        csv << (product.attributes.values_at(*ccn) << product.campaign_medium.medium)
      end
    end
  end

  def builded_url
    uri = URI.parse(url)
    new_query_ar = uri.query ? URI.decode_www_form(uri.query) : []

    new_query_ar << ["utm_source", source] if source # 必填 其實不用if
    new_query_ar << ["utm_medium", self.campaign_medium.medium] if self.campaign_medium.medium # 必填 其實不用if
    new_query_ar << ["utm_term", term] if term
    new_query_ar << ["utm_content", content] if content
    new_query_ar << ["utm_name", name] if name # 必填 其實不用if

    uri.query = URI.encode_www_form(new_query_ar)
    return uri.to_s

    # result = url
    # result += result.include?('?') ? '&' : '?'
    # result += "utm_source=#{source}" if source # 必填
    # # result += "&utm_medium=#{campaign_medium}" if campaign_medium # 必填
    # result += "&utm_term=#{term}" if term
    # result += "&utm_content=#{content}" if content
    # result += "&utm_name=#{name}" if name # 必填
    # return result
  end

  def short_url_info
    return "#{short_url}.info"
  end

  def self.fetch_and_save_short_url_analytics_all
    self.find_in_batches.with_index do |group, batch|
      # puts "Processing group ##{batch}"
      group.each(&:fetch_and_save_short_url_analytics)
    end
  end

  # TODO: 順便儲存在Redis裡面 不反覆抓取
  def fetch_and_save_short_url_analytics
    url = "https://www.googleapis.com/urlshortener/v1/url?key=#{ENV["GOOGLE_API_KEY"]}&shortUrl=#{self.short_url}&projection=FULL"
    result = open(url).read
    result = JSON.parse(result)
    ua = UrlAnalytic.create(json: result, url_builder: self)
    # self.url_analytics.create(json: result)
    return ua.json
  end

  # def url_analytics
    # name_trans || read_attribute(:url_analytics)
    # read_attribute(:url_analytics)
  # end
  # TODO: 先去看Redis裡面有沒有
  # def url_analytics
    # @url_analytics_result ||= JSON.parse '{
    #  "kind": "urlshortener#url",
    #  "id": "http://goo.gl/bgaA8I",
    #  "longUrl": "http://localhost:3000/url_builders?mytest=test&utm_source=_builders?mytest=test&utm_term=_builders?mytest=test&utm_content=_builders?mytest=test&utm_name=_builders?mytest=test",
    #  "status": "OK",
    #  "created": "2016-05-05T08:05:25.355+00:00",
    #  "analytics": {
    #   "allTime": {
    #    "shortUrlClicks": "2",
    #    "longUrlClicks": "2",
    #    "referrers": [
    #     {
    #      "count": "2",
    #      "id": "unknown"
    #     }
    #    ],
    #    "countries": [
    #     {
    #      "count": "2",
    #      "id": "TW"
    #     }
    #    ],
    #    "browsers": [
    #     {
    #      "count": "2",
    #      "id": "Chrome"
    #     }
    #    ],
    #    "platforms": [
    #     {
    #      "count": "2",
    #      "id": "Macintosh"
    #     }
    #    ]
    #   },
    #   "month": {
    #    "shortUrlClicks": "2",
    #    "longUrlClicks": "2",
    #    "referrers": [
    #     {
    #      "count": "2",
    #      "id": "unknown"
    #     }
    #    ],
    #    "countries": [
    #     {
    #      "count": "2",
    #      "id": "TW"
    #     }
    #    ],
    #    "browsers": [
    #     {
    #      "count": "2",
    #      "id": "Chrome"
    #     }
    #    ],
    #    "platforms": [
    #     {
    #      "count": "2",
    #      "id": "Macintosh"
    #     }
    #    ]
    #   },
    #   "week": {
    #    "shortUrlClicks": "2",
    #    "longUrlClicks": "2",
    #    "referrers": [
    #     {
    #      "count": "2",
    #      "id": "unknown"
    #     }
    #    ],
    #    "countries": [
    #     {
    #      "count": "2",
    #      "id": "TW"
    #     }
    #    ],
    #    "browsers": [
    #     {
    #      "count": "2",
    #      "id": "Chrome"
    #     }
    #    ],
    #    "platforms": [
    #     {
    #      "count": "2",
    #      "id": "Macintosh"
    #     }
    #    ]
    #   },
    #   "day": {
    #    "shortUrlClicks": "0",
    #    "longUrlClicks": "0"
    #   },
    #   "twoHours": {
    #    "shortUrlClicks": "0",
    #    "longUrlClicks": "0"
    #   }
    #  }
    # }'
    # return @url_analytics_result


    # return fetch_and_save_short_url_analytics
  # end

  private
    def set_short_url # 只是set 不會儲存
      result = RestClient.post( "https://www.googleapis.com/urlshortener/v1/url\?key\=#{ENV["GOOGLE_API_KEY"]}", {"longUrl": "#{builded_url}"}.to_json, :content_type => :json, :accept => :json )
      # result = `curl https://www.googleapis.com/urlshortener/v1/url\?key\=#{ENV["GOOGLE_API_KEY"]} -H 'Content-Type: application/json' -d '{"longUrl": "#{builded_url}"}'`
      self.short_url = JSON.parse(result)["id"]
    end

    def self.csv_column_names
      cn = column_names
      cn.delete("id")
      cn.delete("user_id")
      cn.delete("campaign_medium_id")
      cn << "campaign_medium"
      return cn
    end
end
