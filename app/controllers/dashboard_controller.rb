class DashboardController < ApplicationController

  before_action :authorize, only: [:index]

  def index
    @warring = create_warrings

    @analytics = Analytics.new current_user
    profile_id = current_user.account_summary.default_profile

    @grpah1Data7 = @analytics.get_users_sessions_goalCompletionsAll_pageViews(profile_id, "7daysAgo", "yesterday")
    begin
      @grpah1Data7 = @grpah1Data7.totals_for_all_results
      @grpah1Data7 = {
        sessions: @grpah1Data7["ga:sessions"],
        users: @grpah1Data7["ga:users"],
        pageviews: @grpah1Data7["ga:pageviews"],
        goalCompletionsAll: @grpah1Data7["ga:goalCompletionsAll"]
      }
    rescue ExceptionName
      @grpah1Data7 = {
        sessions: 0,
        users: 0,
        pageviews: 0,
        goalCompletionsAll: 0
      }
    end

    @grpah1Data30 = @analytics.get_users_sessions_goalCompletionsAll_pageViews(profile_id, "30daysAgo", "yesterday")
    begin
      @grpah1Data30 = @grpah1Data30.totals_for_all_results
      @grpah1Data30 = {
        sessions: @grpah1Data30["ga:sessions"],
        users: @grpah1Data30["ga:users"],
        pageviews: @grpah1Data30["ga:pageviews"],
        goalCompletionsAll: @grpah1Data30["ga:goalCompletionsAll"]
      }
    rescue ExceptionName
      @grpah1Data30 = {
        sessions: 0,
        users: 0,
        pageviews: 0,
        goalCompletionsAll: 0
      }
    end

    @grpah2Data = @analytics.get_visits_all_and_new(profile_id, "183daysAgo", "yesterday")
    @grpah2DataOldVisitors = []
    @grpah2Data.rows.each{|obj|
      @grpah2DataOldVisitors << [obj[0], (obj[1].to_i - obj[2].to_i).to_s ]
    }
    @grpah2Data.rows.map{|obj| obj.delete_at(1) }
    @grpah2DataNewVisitors = @grpah2Data.rows


    # Date.strptime(@grpah2Data.rows.first.first, "%Y%m%d")
    # byebug

    # nthWeek ga:sessions ga:users ga:pageviews ga:goalCompletionsAll
    @grpah3Data = @analytics.get_users_sessions_goalCompletionsAll_pageViews_div_nthweek(profile_id, "49daysAgo", "yesterday").rows
    now = Date.today
    sum_latitude = 0
    @grpah3Data = @grpah3Data.map{|obj|
      sum_latitude += obj[3].to_i;
      {
        "date" => "#{now-7*obj[0].to_i}",
        "distance" => obj[2], # Users
        "latitude" => obj[3], # Predicated Page Views
        "duration" => obj[3]  # Page Views
        # "distance" => 10,
        # "latitude" => 20,
        # "duration" => 30,
      }
    }.reverse
    @grpah3Data.last["bulletClass"] = "lastBullet"
    @grpah3Data.last["latitude"] = (sum_latitude.to_f/@grpah3Data.size).to_s
    @grpah3Data << {
      "date" => "#{now+7}"
    }

    @grpah5Data = @analytics.get_sessions_goalCompletionsAll_div_source(profile_id, "30daysAgo", "yesterday").rows.reverse
    @grpah5Data = @grpah5Data.first(6)
    @grpah5Data.map!{|obj|
      {
          "year" => obj[0],
          "income" => obj[1].to_f,
          "expenses" => obj[2].to_f
      }
    }
  end

  private

  def create_warrings
    @analytics ||= Analytics.new current_user
    profile_id = current_user.account_summary.default_profile

    ###
    @visits = @analytics.get_visits(profile_id, "7daysAgo", "yesterday")
    ###

    ###
    # 測試1
    @act_users = @analytics.get_realtime_data(profile_id)
    @act_users = @act_users.totals_for_all_results["rt:activeUsers"]
    ###

    #TODO: 太肥大 重構
    warring ={}
    warring[:event_sessions] = []
    @event_sessions = @analytics.get_event_sessions(profile_id)
    # if @event_sessions.rows && @event_sessions.rows[0][-1] == "0" && !@event_sessions.rows[0][0].empty?
    if @event_sessions.rows
      # @warring[:event_sessions] = @event_sessions.rows[0]
      @event_sessions.rows.each do |row|
        warring[:event_sessions] << row if row[-1].to_i == 0
      end
    end

    #TODO: Dirty Hack, 先有功能就好，日後重構
    user_ga_campaigns = GaCampaign.where(user: current_user)
    _start = "7daysAgo"
    max_date = (Date.today-7)
    if user_ga_campaigns.size > 0
      max_date = GaCampaign.where(user: current_user).maximum(:date)
      _start = "#{(Date.today-max_date).to_i}daysAgo"

    end

    #TODO: 這個IF條件也是Dirty Hack
    if((Date.today-max_date).to_i > 0) # 當最大日期不是今天才要抓
      @campaign_sessions = @analytics.get_campaign_sessions(profile_id, _start, "yesterday")
      #TODO: 做法錯誤，不能全塞進去，
      # 1. 取資料時，就不取回重複日期
      # 2. 儲存時，不儲存重複日期
      GaCampaign.create(@campaign_sessions.rows.map{|row|
        row={source: row[0], medium: row[1], date: row[2], sessions: row[3], user:current_user}
      }) if @campaign_sessions.rows #TODO if false 要寫入Log紀錄 Bug
    end

    warring[:campaign_sessions] = [] # 下面的警告先在這邊初始化

    # 活動過期警告
    # warring[:campaign_expired]
    # 檢查過期或即將過期的UrlBuilder
    user_url_builders = UrlBuilder.where(profile: profile_id).where(user: current_user).where(['end_date < ?', Date.today])
    user_url_builders.each do |ub|
      warring[:campaign_sessions] << ["活動已過期", ub.name]
    end

    # 檢查其他
    user_url_builders = UrlBuilder.where(profile: profile_id).where(user: current_user).where(['end_date >= ?', Date.today])

    user_url_builders.each do |ub|
      warring[:campaign_sessions] << ["無此Source", ub.source] if GaCampaign.where(user: current_user, source: ub.source).empty?
    end

    #TODO: 迫不得已的 Dirty Hack
    user_url_builders.each do |ub|
      user_ga_campaigns = GaCampaign.where(user: current_user, sessions: 0, source: ub.source, medium: ub.campaign_medium.medium).where(['date >= ?', Date.today-7]).order(date: :desc)
      warring[:campaign_sessions] << ["此設定近七日出現sessions數為0", ub.url, ub.source, ub.campaign_medium.medium] unless user_ga_campaigns.empty?
      # user_ga_campaigns.each do |ugc|
      #   warring[:campaign_sessions] << ["此設定近七日出現sessions數為0", ub.url, ub.source, ub.campaign_medium.medium]
      # end
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
