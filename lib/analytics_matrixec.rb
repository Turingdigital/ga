# # Copyright 2016 Google Inc.
# #
# # Licensed under the Apache License, Version 2.0 (the "License");
# # you may not use this file except in compliance with the License.
# # You may obtain a copy of the License at
# #
# #      http://www.apache.org/licenses/LICENSE-2.0
# #
# # Unless required by applicable law or agreed to in writing, software
# # distributed under the License is distributed on an "AS IS" BASIS,
# # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# # See the License for the specific language governing permissions and
# # limitations under the License.
#
# require 'google/apis/analytics_v3'
# # require 'google/apis/servicemanagement_v1'
# # https://github.com/google/google-api-ruby-client/blob/master/generated/google/apis/analytics_v3.rb
# require 'googleauth'
#
# # require Rails.env.development? ? 'googleauth/stores/file_token_store' : 'googleauth/stores/redis_token_store'
# require 'googleauth/stores/file_token_store'
# GA_DATA_REDIS_EXPIRE_TIME = 60*60*8
#
# module Authorizer
#   CALLBACK_URI = 'http://localhost:3000/oauth/ga_callback'
#   CLIENT_ID = Google::Auth::ClientId.new('782362301580-bnlu7s7gmjv9htlh65837ufjes6ptd37.apps.googleusercontent.com', '2dZLlxRKmeSqT5QmAl6tOPXC')
#   SCOPE = [Google::Apis::AnalyticsV3::AUTH_ANALYTICS, Google::Apis::DriveV3::AUTH_DRIVE]
#   # ref https://github.com/redis/redis-rb
#   # redis = Redis.new(:host => "10.0.1.1", :port => 6380, :db => 0, :path => "/tmp/redis.sock", :password => "mysecret")
#
#   TOKEN_STORE = Google::Auth::Stores::FileTokenStore.new(:file => Rails.root+"google_auth_stores")
#
#   AUTHORIZER = Google::Auth::UserAuthorizer.new(CLIENT_ID, SCOPE, TOKEN_STORE, CALLBACK_URI)
#
#   def self.credentials user_id
#     return AUTHORIZER.get_credentials(user_id)
#   end
#
#   def self.store_credentials(user_id, credentials)
#     AUTHORIZER.store_credentials(user_id, credentials)
#   end
# end

class AnalyticsMatrixec < Analytics #< BaseCli

  # @@OOB_URI = 'http://localhost:3000/oauth/ga_callback'
  # @@CALLBACK_URI = 'http://localhost:3000/oauth/ga_callback'
  # @@client_id = Google::Auth::ClientId.new('782362301580-bnlu7s7gmjv9htlh65837ufjes6ptd37.apps.googleusercontent.com', '2dZLlxRKmeSqT5QmAl6tOPXC')

  # def initialize user
  #   @user = user
  #   @analytics = Google::Apis::AnalyticsV3::AnalyticsService.new
  #   @redis = Redis.new(
  #     host: 'localhost',
  #     port: 6379,
  #     db: 2)
  # end

  # 批量檢查認證
  # User.all.each{|u| puts Analytics.new(u).authorize ? "OK:#{u.email}" : "Fail:#{u.email}"}
  # def authorize
  #   @analytics.authorization = Authorizer.credentials(@user.email)
  #   return @analytics.authorization ? true : false
  # end

  # def reload_authorizer_store_credentials_from_model
  #   # authorizer.store_credentials('isaac@adup.com.tw', cred)
  #   Authorizer.store_credentials(@user.email, @user.ga_credential)
  # end

  # 有自己的Model儲存，所以不用Cache
  # def accountSummaries
  #   # unless self.authorized?
  #   # result = get_cached profile_id, _start, _end
  #   # return result if result
  #
  #   authorize
  #
  #   begin
  #     result = @analytics.list_account_summaries
  #     # set_cached(result, profile_id, _start, _end)
  #     # return get_cached profile_id, _start, _end
  #     return result
  #   rescue Exception => e
  #     return false
  #   end
  # end

  # 01. 網站基本概覽
  def _01
    metrics = %w( ga:users ga:sessions ga:pageviews ga:avgSessionDuration ga:pageviewsPerSession ga:bounceRate )

    dimensions = nil # %w( userType )
    sort = nil # %w( -ga:pageviews )
    filters = nil # "ga:eventCategory==會員註冊頁" # nil #"ga:eventCategory==滾軸事件"
    segment = nil # "sessions::condition::ga:pagePath=@a_myday/login_start.php;ga:pagePath!@a_myday/member_form.php"
    # start_index = 1001
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, segment, start_index)
  end
  def _01_a
    metrics = %w( ga:sessions )

    dimensions = %w( userType )
    sort = nil # %w( -ga:pageviews )
    filters = nil # "ga:eventCategory==會員註冊頁" # nil #"ga:eventCategory==滾軸事件"
    segment = nil # "sessions::condition::ga:pagePath=@a_myday/login_start.php;ga:pagePath!@a_myday/member_form.php"
    # start_index = 1001
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, segment, start_index)
  end

  # 02_1. 裝置使用比較
  def _02_1 profile_id, _start="7daysAgo", _end="yesterday", start_index=1
    metrics = %w( ga:sessions ga:percentNewSessions ga:newUsers ga:bounceRate ga:pageviewsPerSession ga:avgSessionDuration ga:transactions ga:transactionRevenue ga:transactionsPerSession )

    dimensions = %w( ga:deviceCategory )
    sort = %w( -ga:sessions )
    filters = nil # "ga:eventCategory==會員註冊頁" # nil #"ga:eventCategory==滾軸事件"
    segment = nil # "sessions::condition::ga:pagePath=@a_myday/login_start.php;ga:pagePath!@a_myday/member_form.php"
    # start_index = 1 if start_index.nil?
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, segment, start_index)
  end
  # 02_2. 裝置作業系統使用比較
  def _02_2 profile_id, _start="7daysAgo", _end="yesterday", start_index=1
    metrics = %w( ga:sessions ga:percentNewSessions ga:newUsers ga:bounceRate ga:pageviewsPerSession ga:avgSessionDuration ga:transactions ga:transactionRevenue ga:transactionsPerSession )

    dimensions = %w( ga:operatingSystem )
    sort = %w( -ga:sessions )
    filters = nil # "ga:eventCategory==會員註冊頁" # nil #"ga:eventCategory==滾軸事件"
    segment = nil # "sessions::condition::ga:pagePath=@a_myday/login_start.php;ga:pagePath!@a_myday/member_form.php"
    # start_index = 1 if start_index.nil?
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, segment, start_index)
  end

  # 03. 性別年齡層比較
  def _03 profile_id, _start="7daysAgo", _end="yesterday", start_index=1
    metrics = %w( ga:sessions ga:bounceRate ga:avgSessionDuration ga:pageviewsPerSession )

    dimensions = %w( ga:userAgeBracket ga:userGender ga:userType )
    sort = %w( ga:userGender ga:userType ga:userAgeBracket )
    filters = nil # "ga:eventCategory==會員註冊頁" # nil #"ga:eventCategory==滾軸事件"
    segment = nil # "sessions::condition::ga:pagePath=@a_myday/login_start.php;ga:pagePath!@a_myday/member_form.php"
    # start_index = 1 if start_index.nil?
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, segment, start_index)
  end
  # 03_1. 性別比
  def _03_1 profile_id, _start="7daysAgo", _end="yesterday", start_index=1
    metrics = %w( ga:users ga:newUsers ga:sessions ga:bounceRate ga:pageviewsPerSession ga:avgSessionDuration )

    dimensions = %w( ga:userGender )
    sort = nil # %w( -ga:sessions )
    filters = nil # "ga:eventCategory==會員註冊頁" # nil #"ga:eventCategory==滾軸事件"
    segment = nil # "sessions::condition::ga:pagePath=@a_myday/login_start.php;ga:pagePath!@a_myday/member_form.php"
    # start_index = 1 if start_index.nil?
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, segment, start_index)
  end
  # 03_2. 年齡層
  def _03_2 profile_id, _start="7daysAgo", _end="yesterday", start_index=1
    metrics = %w( ga:users ga:newUsers ga:sessions ga:bounceRate ga:pageviewsPerSession ga:avgSessionDuration )

    dimensions = %w( ga:userAgeBracket )
    sort = nil # %w( -ga:sessions )
    filters = nil # "ga:eventCategory==會員註冊頁" # nil #"ga:eventCategory==滾軸事件"
    segment = nil # "sessions::condition::ga:pagePath=@a_myday/login_start.php;ga:pagePath!@a_myday/member_form.php"
    # start_index = 1 if start_index.nil?
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, segment, start_index)
  end

  # 05. 來源/媒介帶來的轉換比較
  def _05 profile_id, _start="7daysAgo", _end="yesterday", start_index=1
    metrics = %w( ga:sessions ga:percentNewSessions ga:newUsers ga:bounceRate ga:pageviewsPerSession ga:avgSessionDuration ga:transactions ga:transactionRevenue )

    dimensions = %w( ga:sourceMedium )
    sort = %w( -ga:sessions )
    filters = nil # "ga:eventCategory==會員註冊頁" # nil #"ga:eventCategory==滾軸事件"
    segment = nil # "sessions::condition::ga:pagePath=@a_myday/login_start.php;ga:pagePath!@a_myday/member_form.php"
    # start_index = 1 if start_index.nil?
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, segment, start_index)
  end


  # 11. 小時年齡熱點
  def _11 profile_id, _start="7daysAgo", _end="yesterday", start_index=1
    metrics = %w( ga:sessions ga:transactions ga:transactionRevenue )

    dimensions = %w( ga:date ga:hour ga:userAgeBracket )
    sort = nil # %w( -ga:pageviews )
    filters = nil # "ga:eventCategory==會員註冊頁" # nil #"ga:eventCategory==滾軸事件"
    segment = nil # "sessions::condition::ga:pagePath=@a_myday/login_start.php;ga:pagePath!@a_myday/member_form.php"
    # start_index = 1 if start_index.nil?
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, segment, start_index)
  end

  # 12. 波士頓矩陣
  def _12 profile_id, _start="7daysAgo", _end="yesterday", start_index=1
    # byebug if Rails.env == "development"
    # metrics = %w( ga:productListViews ga:uniquePurchases ga:productDetailViews)
    # dimensions = %w( ga:productName ga:productCategory ga:productCategoryHierarchy )

    metrics = %w( ga:productListViews ga:productDetailViews ga:uniquePurchases )
    dimensions = %w( ga:productCategoryHierarchy )

    sort = nil # %w( -ga:pageviews )
    filters = nil # "ga:eventCategory==會員註冊頁" # nil #"ga:eventCategory==滾軸事件"
    segment = nil # "sessions::condition::ga:pagePath=@a_myday/login_start.php;ga:pagePath!@a_myday/member_form.php"
    # start_index = 1 if start_index.nil?
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, segment, start_index)
  end

  def get_ga_data profile_id, _start, _end, metrics, dimensions=nil, sort=nil, filters=nil, segment=nil, start_index=nil
    caller_method_name ||= (caller[0][/`.*'/][1..-2]+(filters.nil? ? "nofilter" : filters.to_s))

    # byebug
    # byebug if Rails.env == "development"
    result = get_cached(profile_id, _start, _end, caller_method_name, start_index)
    return result if result && !(caller_method_name =~ /page1|sstainan/)

    authorize

    arg = {}
    arg[:dimensions] = dimensions.join(',') if dimensions
    arg[:sort] = sort.join(',') if sort
    arg[:filters] = filters if filters # 假流量篩sessions
    arg[:segment] = segment if segment
    arg[:start_index] = start_index if start_index

    result = @analytics.get_ga_data( "ga:#{profile_id}", _start, _end, metrics.join(','), arg)

    set_cached(result, profile_id, _start, _end, caller_method_name, start_index)
    return get_cached(profile_id, _start, _end, caller_method_name, start_index)
  end

  def list_segments
    result = @analytics.list_segments
    return result
  end

  private
    def get_cached profile_id, _start, _end, caller_method_name=nil, start_index
      caller_method_name ||= caller[0][/`.*'/][1..-2]
      result = @redis.get("#{@user.email}:#{profile_id}:#{_start}:#{_end}:#{caller_method_name}:#{start_index}")
      return result ? JSON.parse(result) : nil
    end

    def set_cached result, profile_id, _start, _end, caller_method_name=nil, start_index=1
      caller_method_name ||= caller[0][/`.*'/][1..-2]
      redis_key = "#{@user.email}:#{profile_id}:#{_start}:#{_end}:#{caller_method_name}:#{start_index}"
      @redis.set redis_key, result.to_json
      @redis.expire redis_key, GA_DATA_REDIS_EXPIRE_TIME
    end
end

# ga:source==Line;ga:medium==POST;ga:adContent==line_圖文_午;ga:campaign==170313-24_野餐用品;ga:keyword==line_每日po文_item_10
