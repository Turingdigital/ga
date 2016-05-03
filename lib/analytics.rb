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
require 'googleauth/stores/redis_token_store'

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
class Analytics #< BaseCli

  @@OOB_URI = 'http://localhost:3000/oauth/ga_callback'
  @@CALLBACK_URI = 'http://localhost:3000/oauth/ga_callback'
  @@client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])

  def initialize user
    scope = Google::Apis::AnalyticsV3::AUTH_ANALYTICS

    @user = user
    token_store = Google::Auth::Stores::RedisTokenStore.new({redis: 'localhost', prefix: "ga_user_#{@user.email}"})
    @authorizer = Google::Auth::UserAuthorizer.new(@@client_id, scope, token_store, @@CALLBACK_URI)

    @analytics = Google::Apis::AnalyticsV3::AnalyticsService.new
    @analytics.authorization = self.credentials #user_credentials_for(scope)
  end

  def credentials
    @authorizer.get_credentials(@user.email)
  end

  def oauth_url
    url = @authorizer.get_authorization_url(base_url: @@OOB_URI)
  end

  # desc 'show_visits PROFILE_ID', 'Show visists for the given analytics profile ID'
  # method_option :start, type: :string, required: true
  # method_option :end, type: :string, required: true
  def show_visits(profile_id, _start, _end)
    dimensions = %w(ga:date)
    metrics = %w(ga:sessions ga:users ga:newUsers ga:percentNewSessions
                 ga:sessionDuration ga:avgSessionDuration)
    sort = %w(ga:date)
    result = @analytics.get_ga_data("ga:#{profile_id}",
                                    _start, _end,
                                    metrics.join(','),
                                    dimensions: dimensions.join(','),
                                    sort: sort.join(','))

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

  def accountSummaries
    @analytics.list_account_summaries
  end

  def oauth_url
    url = @authorizer.get_authorization_url(base_url: @@OOB_URI)
  end

end
