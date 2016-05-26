class DashboardController < ApplicationController

  before_action :authorize, only: [:index]

  def index
    @analytics = Analytics.new current_user
    profile_id = current_user.account_summary.default_profile

    @warring = {}

    # 測試1
    @act_users = @analytics.get_realtime_data(profile_id)

    # 測試2
    @event_sessions = @analytics.get_event_sessions(profile_id)
    if @event_sessions.rows && @event_sessions.rows[0][-1] == "0" && !@event_sessions.rows[0][0].empty?
      @warring[:event_sessions] = @event_sessions.rows[0]
    end

    # 測試3
    @campaign_sessions = @analytics.get_campaign_sessions(profile_id)

  end

  def authorize
    edirect_to root_path unless user_signed_in?
    if current_user.account_summary.default_profile.nil?
      redirect_to(account_summary_url(current_user.account_summary), flash: {alert: "你尚未設定預設設定檔"})
    end
  end
end
