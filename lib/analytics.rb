# Copyright 2016 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'google/apis/analytics_v3'
require 'googleauth'

# require Rails.env.development? ? 'googleauth/stores/file_token_store' : 'googleauth/stores/redis_token_store'
require 'googleauth/stores/file_token_store'
GA_DATA_REDIS_EXPIRE_TIME = 60*60*8

module Authorizer
  CALLBACK_URI = 'http://localhost:3000/oauth/ga_callback'
  CLIENT_ID = Google::Auth::ClientId.new('782362301580-bnlu7s7gmjv9htlh65837ufjes6ptd37.apps.googleusercontent.com', '2dZLlxRKmeSqT5QmAl6tOPXC')
  SCOPE = Google::Apis::AnalyticsV3::AUTH_ANALYTICS
  # ref https://github.com/redis/redis-rb
  # redis = Redis.new(:host => "10.0.1.1", :port => 6380, :db => 0, :path => "/tmp/redis.sock", :password => "mysecret")

  TOKEN_STORE = Google::Auth::Stores::FileTokenStore.new(:file => Rails.root+"google_auth_stores")

  AUTHORIZER = Google::Auth::UserAuthorizer.new(CLIENT_ID, SCOPE, TOKEN_STORE, CALLBACK_URI)

  def self.credentials user_id
    return AUTHORIZER.get_credentials(user_id)
  end

  def self.store_credentials(user_id, credentials)
    AUTHORIZER.store_credentials(user_id, credentials)
  end
end

class Analytics #< BaseCli

  # @@OOB_URI = 'http://localhost:3000/oauth/ga_callback'
  # @@CALLBACK_URI = 'http://localhost:3000/oauth/ga_callback'
  # @@client_id = Google::Auth::ClientId.new('782362301580-bnlu7s7gmjv9htlh65837ufjes6ptd37.apps.googleusercontent.com', '2dZLlxRKmeSqT5QmAl6tOPXC')

  def initialize user
    @user = user
    @analytics = Google::Apis::AnalyticsV3::AnalyticsService.new
    @redis = Redis.new(
      host: 'localhost',
      port: 6379,
      db: 2)
  end

  # 批量檢查認證
  # User.all.each{|u| puts Analytics.new(u).authorize ? "OK:#{u.email}" : "Fail:#{u.email}"}
  def authorize
    @analytics.authorization = Authorizer.credentials(@user.email)
    return @analytics.authorization ? true : false
  end

  def reload_authorizer_store_credentials_from_model
    # authorizer.store_credentials('isaac@adup.com.tw', cred)
    Authorizer.store_credentials(@user.email, @user.ga_credential)
  end

  # 有自己的Model儲存，所以不用Cache
  def accountSummaries
    # unless self.authorized?
    # result = get_cached profile_id, _start, _end
    # return result if result

    authorize

    begin
      result = @analytics.list_account_summaries
      # set_cached(result, profile_id, _start, _end)
      # return get_cached profile_id, _start, _end
      return result
    rescue Exception => e
      return false
    end
  end

  def show_visits(profile_id, _start, _end)
    dimensions = %w(ga:date)
    metrics = %w(ga:sessions ga:users ga:newUsers ga:percentNewSessions
                 ga:sessionDuration ga:avgSessionDuration)
    sort = %w(ga:date)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort)
  end

  def get_visits(profile_id, _start, _end)
    dimensions = %w(ga:date)
    metrics = %w(ga:sessions ga:users ga:newUsers ga:percentNewSessions
                 ga:sessionDuration ga:avgSessionDuration)
    sort = %w(ga:date)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort)
  end

  def get_visits_all_and_new(profile_id, _start, _end)
    dimensions = %w(ga:yearMonth)
    metrics = %w(ga:users ga:newUsers)
    sort = %w(ga:yearMonth)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort)
  end

  # ga:source==Line;ga:medium==POST;ga:adContent==line_圖文_午;ga:campaign=="170313-24_野餐用品";ga:keyword==line_每日po文_item_10
  # 都要變小寫
  def get_sessions_filter_canpaign_today(
        profile_id,
        source,
        medium,
        adContent,
        campaign,
        keyword,
        _start="today",
        _end="today")
    metrics = %w(ga:sessions)
    # dimensions = %w(ga:nthHour)
    filter = "ga:source==#{source};ga:medium==#{medium};ga:adContent==#{adContent};ga:campaign==#{campaign};ga:keyword==#{keyword}"
    # sort = %w(-ga:searchResultViews)
    return get_ga_data(profile_id, _start, _end, metrics, nil, nil, filter)
  end

  def get_searchs_div_searchKeyword(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w(ga:searchResultViews ga:percentSearchRefinements ga:searchExitRate)
    dimensions = %w(ga:searchKeyword)
    sort = %w(-ga:searchResultViews)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort)
  end

  def get_users_sessions_goalCompletionsAll_pageViews(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w(ga:sessions ga:users ga:pageviews ga:goalCompletionsAll)
    return get_ga_data(profile_id, _start, _end, metrics)
  end

  def get_users_sessions_goalCompletionsAll_pageViews_div_nthweek(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w(ga:sessions ga:users ga:pageviews ga:goalCompletionsAll)
    dimensions = %w(ga:nthWeek)
    sort = %w(ga:nthWeek)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort)
  end

  def get_sessions_goalCompletionsAll_div_source(profile_id, _start="30daysAgo", _end="yesterday")
    metrics = %w(ga:sessions ga:goalCompletionsAll)
    dimensions = %w(ga:source)
    sort = %w(ga:sessions)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort)
  end

  def get_sessions profile_id, _start="7daysAgo", _end="yesterday"
    metrics = %w(ga:sessions)
    return get_ga_data(profile_id, _start, _end, metrics)
  end

  def get_campaign_sessions profile_id, _start="7daysAgo", _end="yesterday"
    dimensions = %w(ga:source ga:medium ga:date)
    metrics = %w(ga:sessions)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions)
  end

  def get_sourceMedium_sessions profile_id, _start="7daysAgo", _end="yesterday"
    dimensions = %w(ga:sourceMedium)
    metrics = %w(ga:sessions)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions)
  end

  def get_event_sessions profile_id, _start="7daysAgo", _end="yesterday"
    dimensions = %w(ga:eventCategory ga:eventAction ga:eventLabel)
    metrics = %w(ga:sessions)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions)
  end

  def list_goals options={} #accountId, webPropertyId, profileId
    result = get_cached profile_id, _start, _end
    return result if result

    authorize

    accountId     = '~all' unless options[:accountId]
    webPropertyId = '~all' unless options[:webPropertyId]
    profileId     = '~all' unless options[:profileId]
    result = @analytics.list_goals(accountId, webPropertyId, profileId)
    set_cached(result, profile_id, _start, _end)
    return get_cached profile_id, _start, _end
  end

  def get_realtime_data(profile_id)
    result = get_cached profile_id, 'realtime', 'realtime'
    return result if result

    authorize

    dimensions = %w(ga:date)
    metrics = %w(rt:activeUsers)
    result = @analytics.get_realtime_data("ga:#{profile_id}", metrics.join(','))
    set_cached(result, profile_id, 'realtime', 'realtime')
    return get_cached profile_id, 'realtime', 'realtime'
  end

  # def oauth_url
  #   url = @authorizer.get_authorization_url(base_url: @@OOB_URI)
  # end


  ###########
  # HOT Car #
  ###########
  def page1(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:users
                  ga:sessions
                  ga:pageviews
                  ga:bounceRate
                  ga:avgSessionDuration
                  ga:newUsers )
    dimensions = nil # %w(ga:deviceCategory)
    # sort = %w(-ga:searchResultViews)
    # filters = %w(ga:deviceCategory!=desktop)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, nil, filters)
  end
  def page1_1(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:users
                  ga:sessions )

    dimensions = nil # %w(ga:deviceCategory)
    # sort = %w(-ga:searchResultViews)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, nil, filters)
  end

  def event_1(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w(ga:eventAction )
    # sort = %w(-ga:searchResultViews)
    filters = %w(ga:eventCategory==首頁:左側搜尋)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, nil, filters)
  end

  def event_2(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w(ga:eventAction )
    sort = %w(-ga:totalEvents)
    filters = %w(ga:eventCategory==首頁:快速搜尋)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_3(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w(ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==首頁:快速搜尋;ga:eventAction==搜尋廠牌"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_4(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w(ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==首頁:快速搜尋;ga:eventAction==搜尋車型"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_5(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventAction ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==首頁:快速搜尋;ga:eventAction=@搜尋年份"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_6(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==首頁:快速搜尋;ga:eventAction==搜尋城市"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_7(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==首頁:快速搜尋;ga:eventAction==搜尋區域"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_8(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventAction ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==知識專區"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_9(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventAction ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==最新消息"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_10(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w( ga:eventAction )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==全站:右側頁籤"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_11(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==首頁:白金/金質車商"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_12(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==首頁:熱門/成交車商"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_13(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w( ga:eventAction )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==首頁:熱門/成交車商"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_14(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==手機版"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_15(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==選擇器;ga:eventAction==手機版選擇器: 選取廠牌"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_16(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==選擇器;ga:eventAction==手機版選擇器: 選取車型"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  private
    def get_cached profile_id, _start, _end, caller_method_name=nil
      caller_method_name ||= caller[0][/`.*'/][1..-2]
      result = @redis.get("#{@user.email}:#{profile_id}:#{_start}:#{_end}:#{caller_method_name}")
      return result ? JSON.parse(result) : nil
    end

    def set_cached result, profile_id, _start, _end, caller_method_name=nil
      caller_method_name ||= caller[0][/`.*'/][1..-2]
      redis_key = "#{@user.email}:#{profile_id}:#{_start}:#{_end}:#{caller_method_name}"
      @redis.set redis_key, result.to_json
      @redis.expire redis_key, GA_DATA_REDIS_EXPIRE_TIME
    end

    def get_ga_data profile_id, _start, _end, metrics, dimensions=nil, sort=nil, filters=nil
      caller_method_name ||= (caller[0][/`.*'/][1..-2]+(filters.nil? ? "nofilter" : filters.to_s))

      result = get_cached(profile_id, _start, _end, caller_method_name)
      return result if result #&& caller_method_name != "page1_1"

      authorize

      arg = {}
      arg[:dimensions] = dimensions.join(',') if dimensions
      arg[:sort] = sort.join(',') if sort
      arg[:filters] = filters if filters
      result = @analytics.get_ga_data(
                            "ga:#{profile_id}",
                            _start, _end,
                            metrics.join(','),
                            arg)

      set_cached(result, profile_id, _start, _end, caller_method_name)
      return get_cached(profile_id, _start, _end, caller_method_name)
    end
end

# ga:source==Line;ga:medium==POST;ga:adContent==line_圖文_午;ga:campaign==170313-24_野餐用品;ga:keyword==line_每日po文_item_10
