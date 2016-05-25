class DashboardController < ApplicationController
  def index
    @analytics = Analytics.new current_user
    profile_id = current_user.account_summary.default_profile

    # 測試1
    @act_users = @analytics.get_realtime_data(profile_id)
    # 測試2
    @event_sessions = @analytics.get_event_sessions(profile_id)
  end
end
