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

require Rails.env.development? ? 'googleauth/stores/file_token_store' : 'googleauth/stores/redis_token_store'

# Examples for the Google Analytics APIs
#
# Sample usage session:
#
#     $ ./google-api-samples analytics show_visits 55622900 --start='2015-12-01' --end='2015-12-08'
#     ga:date   ga:sessions  ga:users  ga:newUsers  ga:percentNewSessions  ga:sessionDuration  ga:avgSessionDuration
#     20151201  0            0         0            0.0                    0.0                 0.0
#     20151202  0            0         0            0.0                    0.0                 0.0
#     20151203  1            1         1            100.0                  0.0                 0.0
#     20151204  2            2         1            50.0                   616.0               308.0
#     20151205  0            0         0            0.0                    0.0                 0.0
#     20151206  1            1         1            100.0                  0.0                 0.0
#     20151207  0            0         0            0.0                    0.0                 0.0
#     20151208  2            2         1            50.0                   0.0                 0.0
#

module Authorizer
  CALLBACK_URI = 'http://localhost:3000/oauth/ga_callback'
  CLIENT_ID = Google::Auth::ClientId.new('782362301580-bnlu7s7gmjv9htlh65837ufjes6ptd37.apps.googleusercontent.com', '2dZLlxRKmeSqT5QmAl6tOPXC')
  SCOPE = Google::Apis::AnalyticsV3::AUTH_ANALYTICS
  # ref https://github.com/redis/redis-rb
  # redis = Redis.new(:host => "10.0.1.1", :port => 6380, :db => 0, :path => "/tmp/redis.sock", :password => "mysecret")

  TOKEN_STORE = Rails.env.development? ?
    Google::Auth::Stores::FileTokenStore.new(:file => Rails.root+"google_auth_stores") :
    Google::Auth::Stores::RedisTokenStore.new({prefix: "ga:user:", host: ENV["REDIS_PORT_6379_TCP_ADDR"], port: ENV["REDIS_PORT_6379_TCP_PORT"]})

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
    # @analytics.authorization = Authorizer.credentials(@user.email) #user_credentials_for(scope)
  end

  def authorize
    @analytics.authorization = Authorizer.credentials(@user.email)
    return @analytics.authorization ? true : false
  end

  def reload_authorizer_store_credentials_from_model
    # authorizer.store_credentials('isaac@adup.com.tw', cred)
    Authorizer.store_credentials(@user.email, @user.ga_credential)
  end

  def accountSummaries
    # unless self.authorized?
    authorize

    begin
      return @analytics.list_account_summaries
    rescue Exception => e
      return false
    end
  end

  # def credentials
  #   @authorizer.get_credentials(@user.email)
  # end

  # def oauth_url
  #   url = @authorizer.get_authorization_url(base_url: @@OOB_URI)
  # end

  # desc 'show_visits PROFILE_ID', 'Show visists for the given analytics profile ID'
  # method_option :start, type: :string, required: true
  # method_option :end, type: :string, required: true
  def show_visits(profile_id, _start, _end)
    authorize

    dimensions = %w(ga:date)
    metrics = %w(ga:sessions ga:users ga:newUsers ga:percentNewSessions
                 ga:sessionDuration ga:avgSessionDuration)
    sort = %w(ga:date)
    result = @analytics.get_ga_data(
                          "ga:#{profile_id}",
                          _start, _end,
                          metrics.join(','),
                          dimensions: dimensions.join(','),
                          sort: sort.join(','))
    return result
    # result = @analytics.get_ga_data("ga:#{profile_id}",
    #                                _start,
    #                                _end,
    #                                metrics.join(','),
    #                                dimensions: dimensions.join(','),
    #                                sort: sort.join(','))

    # data = []
    # data.push(result.column_headers.map { |h| h.name })
    # data.push(*result.rows)
    # data
  end

  def get_visits(profile_id, _start, _end)
    authorize

    dimensions = %w(ga:date)
    metrics = %w(ga:sessions ga:users ga:newUsers ga:percentNewSessions
                 ga:sessionDuration ga:avgSessionDuration)
    sort = %w(ga:date)
    result = @analytics.get_ga_data(
                          "ga:#{profile_id}",
                          _start, _end,
                          metrics.join(','),
                          dimensions: dimensions.join(','),
                          sort: sort.join(','))

    return result
  end

  def get_visits_all_and_new(profile_id, _start, _end)
    authorize

    dimensions = %w(ga:yearMonth)
    metrics = %w(ga:users ga:newUsers)
    sort = %w(ga:yearMonth)
    result = @analytics.get_ga_data(
                          "ga:#{profile_id}",
                          _start, _end,
                          metrics.join(','),
                          dimensions: dimensions.join(','),
                          sort: sort.join(','))

    return result
  end

  def get_users_sessions_goalCompletionsAll_pageViews(profile_id, _start="7daysAgo", _end="yesterday")
    authorize

    metrics = %w(ga:sessions ga:users ga:pageviews ga:goalCompletionsAll)

    result = @analytics.get_ga_data(
                          "ga:#{profile_id}",
                          _start, _end,
                          metrics.join(','))
    return result
  end

  def get_users_sessions_goalCompletionsAll_pageViews_div_nthweek(profile_id, _start="7daysAgo", _end="yesterday")
    authorize

    metrics = %w(ga:sessions ga:users ga:pageviews ga:goalCompletionsAll)
    dimensions = %w(ga:nthWeek)
    sort = %w(ga:nthWeek)
    result = @analytics.get_ga_data(
                          "ga:#{profile_id}",
                          _start, _end,
                          metrics.join(','),
                          dimensions: dimensions.join(','),
                          sort: sort.join(','))
    return result
  end

  def get_sessions profile_id, _start="7daysAgo", _end="yesterday"
    authorize

    metrics = %w(ga:sessions)
    result = @analytics.get_ga_data(
                          "ga:#{profile_id}",
                          _start, _end,
                          metrics.join(','))
    return result
  end

  def get_campaign_sessions profile_id, _start="7daysAgo", _end="yesterday"
    authorize



    dimensions = %w(ga:source ga:medium ga:date)
    metrics = %w(ga:sessions)
    result = @analytics.get_ga_data(
                          "ga:#{profile_id}",
                          _start, _end,
                          metrics.join(','),
                          dimensions: dimensions.join(','))
    return result
  end

  def get_sourceMedium_sessions profile_id, _start="7daysAgo", _end="yesterday"
    authorize

    dimensions = %w(ga:sourceMedium)
    metrics = %w(ga:sessions)
    result = @analytics.get_ga_data(
                          "ga:#{profile_id}",
                          _start, _end,
                          metrics.join(','),
                          dimensions: dimensions.join(','))
    return result
  end

  def get_event_sessions profile_id, _start="7daysAgo", _end="yesterday"
    authorize



    dimensions = %w(ga:eventCategory ga:eventAction ga:eventLabel)
    metrics = %w(ga:sessions)
    result = @analytics.get_ga_data(
                          "ga:#{profile_id}",
                          _start, _end,
                          metrics.join(','),
                          dimensions: dimensions.join(','))
    return result
  end

  # def get_users(profile_id, _start, _end)
  #   authorize
  #
  #   metrics = %w(ga:users)
  #   dimensions = %w(ga:date ga:hour)
  #   result = @analytics.get_ga_data(
  #                         "ga:#{profile_id}",
  #                         _start, _end,
  #                         metrics.join(','),
  #                         dimensions: dimensions.join(','),
  #                         sort: sort.join(','))
  #   return result;
  # end

  def list_goals options={} #accountId, webPropertyId, profileId
    authorize

    accountId     = '~all' unless options[:accountId]
    webPropertyId = '~all' unless options[:webPropertyId]
    profileId     = '~all' unless options[:profileId]
    result = @analytics.list_goals(accountId, webPropertyId, profileId)
    return result
  end

  def get_realtime_data(profile_id)
    authorize

    dimensions = %w(ga:date)
    metrics = %w(rt:activeUsers)
    result = @analytics.get_realtime_data("ga:#{profile_id}", metrics.join(','))
    return result
    # result = @analytics.get_ga_data("ga:#{profile_id}",
    #                                _start,
    #                                _end,
    #                                metrics.join(','),
    #                                dimensions: dimensions.join(','),
    #                                sort: sort.join(','))

    # data = []
    # data.push(result.column_headers.map { |h| h.name })
    # data.push(*result.rows)
    # data
  end

  # def oauth_url
  #   url = @authorizer.get_authorization_url(base_url: @@OOB_URI)
  # end

end
