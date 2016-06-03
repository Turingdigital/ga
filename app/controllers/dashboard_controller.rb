class DashboardController < ApplicationController

  before_action :authorize, only: [:index]

  def index
    @warring = create_warrings
  end

  private

  def create_warrings
    @analytics = Analytics.new current_user
    profile_id = current_user.account_summary.default_profile

    # 測試1
    @act_users = @analytics.get_realtime_data(profile_id)

    #TODO: 太肥大 重構
    warring ={}
    @event_sessions = @analytics.get_event_sessions(profile_id)
    if @event_sessions.rows && @event_sessions.rows[0][-1] == "0" && !@event_sessions.rows[0][0].empty?
      # @warring[:event_sessions] = @event_sessions.rows[0]
      @event_sessions.rows[0].each do |row|
        @warring[:event_sessions] << row if row[-1].to_i == 0
      end
    end

    #TODO: Dirty Hack, 先有功能就好，日後重構
    user_ga_campaigns = GaCampaign.where(user: current_user)
    _start = "7daysAgo"
    if user_ga_campaigns.size > 0
      max_date = GaCampaign.where(user: current_user).maximum(:date)
      _start = "#{max_date.day - Date.today.day}daysAgo"
    end

    if(max_date.day - Date.today.day > 0)
      @campaign_sessions = @analytics.get_campaign_sessions(profile_id, _start, "yesterday")
      #TODO: 做法錯誤，不能全塞進去，
      # 1. 取資料時，就不取回重複日期
      # 2. 儲存時，不儲存重複日期
      GaCampaign.create(@campaign_sessions.rows.map{|row|
        row={source: row[0], medium: row[1], date: row[2], sessions: row[3], user:current_user}
      })
      UrlBuilder.check_campaign_sessions_is_zero current_user
    end

    user_ga_campaigns = GaCampaign.where(user: current_user, sessions: 0).where(['date >= ?', Date.today-7])
    user_url_builders = UrlBuilder.where(user: current_user).where(['end_date >= ?', Date.today])

    #TODO: 迫不得已的 Dirty Hack
    user_url_builders.each do |ub|
      user_ga_campaigns.each do |ugc|
        warring[:campaign_sessions] << "#{ub.url},#{ub.source},#{ub.campaign_medium.medium}"
      end
    end

    return warring
  end

  def authorize
    if user_signed_in?
      if current_user.account_summary.default_profile.nil?
        redirect_to(account_summary_url(current_user.account_summary), flash: {alert: "你尚未設定預設設定檔"})
      end
    else
      redirect_to root_path
    end
  end
end
