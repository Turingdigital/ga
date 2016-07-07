require 'open-uri'

class UrlBuilder < ActiveRecord::Base
  belongs_to :user

  # has_many :url_builder_campaign_mediumships
  # has_many :campaign_media, :through => :url_builder_campaign_mediumships
  has_many :url_analytics, :dependent => :destroy
  belongs_to :campaign_medium

  # def url_shouter
  #   result = `curl https://www.googleapis.com/urlshortener/v1/url\?key\=#{'AIzaSyD2WRzzla118fiEyom6nWML5Ob19FGtTfo'} -H 'Content-Type: application/json' -d '{"longUrl": "http://www.adup.com/"}'`
  # end

  before_save :set_short_url

  def sourceMedium
    return "#{self.source} / #{self.campaign_medium.medium}"
  end

  def self.import file, user
    CSV.foreach(file.path, headers: true, :encoding => 'big5') do |row|
      cm = CampaignMedium.where(medium: row[2])
      cm = cm.empty? ? CampaignMedium.create!(medium: row[2], user: user) : cm.first
      UrlBuilder.create!(
        url: row[0],
        source: row[1],
        campaign_medium: cm,
        name: row[3],
        term: row[4],
        content: row[5],
        start_date: row[6],
        end_date: row[7],
        user: user,
        profile: user.account_summary.default_profile
      )
    end
  end

  def builded_url
    uri = URI.parse(url)
    new_query_ar = uri.query ? URI.decode_www_form(uri.query) : []

    query_map = {}
    unless uri.query.nil?
      URI.decode_www_form(uri.query).each{|q| query_map[q[0]]=q[1]}
    end

    new_query_ar << ["utm_source", source] if !query_map.has_key?("utm_source") && source # 必填 其實不用檢查source
    new_query_ar << ["utm_medium", self.campaign_medium.medium] if !query_map.has_key?("utm_medium") && self.campaign_medium.medium # 必填 其實不用if
    new_query_ar << ["utm_term", term] if !query_map.has_key?("utm_term") && term
    new_query_ar << ["utm_content", content] if !query_map.has_key?("utm_content") && content
    new_query_ar << ["utm_campaign", name] if !query_map.has_key?("utm_campaign") && name # 必填 其實不用if

    uri.query = URI.encode_www_form(new_query_ar)
    return uri.to_s
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
    url = "https://www.googleapis.com/urlshortener/v1/url?key=#{'AIzaSyD2WRzzla118fiEyom6nWML5Ob19FGtTfo'}&shortUrl=#{self.short_url}&projection=FULL"
    result = open(url).read
    # result = JSON.parse(result)
    ua = UrlAnalytic.create(json: result, url_builder: self)
    # self.url_analytics.create(json: result)
    return ua.json
  end

  private
    def set_short_url # 只是set 不會儲存
      uri = URI(url)
      if uri.host == "goo.gl"
        self.short_url = "http://#{uri.host}#{uri.path}"
      else
        begin
          result = RestClient.post( "https://www.googleapis.com/urlshortener/v1/url\?key\=#{'AIzaSyD2WRzzla118fiEyom6nWML5Ob19FGtTfo'}", {"longUrl": "#{builded_url}"}.to_json, :content_type => :json, :accept => :json )
          self.short_url = JSON.parse(result)["id"]
        rescue Exception
          #TODO: 記錄錯誤原因
        end
      end
      # result = `curl https://www.googleapis.com/urlshortener/v1/url\?key\=#{'AIzaSyD2WRzzla118fiEyom6nWML5Ob19FGtTfo'} -H 'Content-Type: application/json' -d '{"longUrl": "#{builded_url}"}'`
    end

    def self.csv_column_names
      cn = column_names
      cn.delete("id")
      cn.delete("user_id")
      cn.delete("campaign_medium_id")
      cn.insert(2, "medium")
      return cn
    end
end
