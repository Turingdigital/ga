class HotcarController < ApplicationController
  before_action :turingdigital_only

  def index
    @analytics = Analytics.new current_user
    profile_id = "23098605"

    today = DateTime.now
    previous_1_month = today << 1
    @previous_1_month = previous_1_month
    previous_1_month_last_day = Date.civil(previous_1_month.year, previous_1_month.month, -1).day
    previous_2_month = today << 2
    @previous_2_month = previous_2_month
    previous_2_month_last_day = Date.civil(previous_2_month.year, previous_2_month.month, -1).day

    day = 1
    @data_pre1_desktop = []
    year_month_pre1_str = "#{previous_1_month.year}-#{('%02d' % previous_1_month.month)}"
    5.times do |n|
      @data_pre1_desktop << @analytics.page1_1(
        profile_id,
        "#{year_month_pre1_str}-#{'%02d' % day}",
        "#{year_month_pre1_str}-#{'%02d' % (n==4 ? previous_1_month_last_day : day+=5)}",
        %w(ga:deviceCategory==desktop))
      day += 1
    end
    day = 1
    @data_pre2_desktop = []
    year_month_pre2_str = "#{previous_2_month.year}-#{('%02d' % previous_2_month.month)}"
    5.times do |n|
      @data_pre2_desktop << @analytics.page1_1(
        profile_id,
        "#{year_month_pre2_str}-#{'%02d' % day}",
        "#{year_month_pre2_str}-#{'%02d' % (n==4 ? previous_2_month_last_day : day+=5)}",
        %w(ga:deviceCategory==desktop))
      day += 1
    end
    day = 1
    @data_pre1_mobile = []
    year_month_str = year_month_pre1_str
    5.times do |n|
      @data_pre1_mobile << @analytics.page1_1(
        profile_id,
        "#{year_month_str}-#{'%02d' % day}",
        "#{year_month_str}-#{'%02d' % (n==4 ? previous_1_month_last_day : day+=5)}",
        %w(ga:deviceCategory!=desktop))
      day += 1
    end
    day = 1
    @data_pre2_mobile = []
    year_month_str = year_month_pre2_str
    5.times do |n|
      @data_pre2_mobile << @analytics.page1_1(
        profile_id,
        "#{year_month_str}-#{'%02d' % day}",
        "#{year_month_str}-#{'%02d' % (n==4 ? previous_2_month_last_day : day+=5)}",
        %w(ga:deviceCategory!=desktop))
      day += 1
    end
    day = 1
    @data_pre1_all = []
    year_month_str = year_month_pre1_str
    5.times do |n|
      @data_pre1_all << @analytics.page1_1(
        profile_id,
        "#{year_month_str}-#{'%02d' % day}",
        "#{year_month_str}-#{'%02d' % (n==4 ? previous_1_month_last_day : day+=5)}")
      day += 1
    end
    day = 1
    @data_pre2_all = []
    year_month_str = year_month_pre2_str
    5.times do |n|
      @data_pre2_all << @analytics.page1_1(
        profile_id,
        "#{year_month_str}-#{'%02d' % day}",
        "#{year_month_str}-#{'%02d' % (n==4 ? previous_2_month_last_day : day+=5)}")
      day += 1
    end

    @basic_data = {
      pre1:{
        all: {sessions:[], users:[]},
        desktop: {sessions:[], users:[]},
        mobile: {sessions:[], users:[]}
      },
      pre2:{
        all: {sessions:[], users:[]},
        desktop: {sessions:[], users:[]},
        mobile: {sessions:[], users:[]}
      },
    }

    @data_pre1_desktop.each do |d|
       @basic_data[:pre1][:desktop][:users] << d["rows"][0][0]
       @basic_data[:pre1][:desktop][:sessions] << d["rows"][0][1]
    end
    @data_pre2_desktop.each do |d|
       @basic_data[:pre2][:desktop][:users] << d["rows"][0][0]
       @basic_data[:pre2][:desktop][:sessions] << d["rows"][0][1]
    end
    @data_pre1_mobile.each do |d|
       @basic_data[:pre1][:mobile][:users] << d["rows"][0][0]
       @basic_data[:pre1][:mobile][:sessions] << d["rows"][0][1]
    end
    @data_pre2_mobile.each do |d|
       @basic_data[:pre2][:mobile][:users] << d["rows"][0][0]
       @basic_data[:pre2][:mobile][:sessions] << d["rows"][0][1]
    end
    @data_pre1_all.each do |d|
       @basic_data[:pre1][:all][:users] << d["rows"][0][0]
       @basic_data[:pre1][:all][:sessions] << d["rows"][0][1]
    end
    @data_pre2_all.each do |d|
       @basic_data[:pre2][:all][:users] << d["rows"][0][0]
       @basic_data[:pre2][:all][:sessions] << d["rows"][0][1]
    end

    year_month_str = year_month_pre1_str
    @page3_all = @analytics.page1(profile_id, "#{year_month_str}-#{'%02d' % 1}",
                              "#{year_month_str}-#{'%02d' % previous_1_month_last_day}")
    @page3_desktop = @analytics.page1(profile_id, "#{year_month_str}-#{'%02d' % 1}",
                              "#{year_month_str}-#{'%02d' % previous_1_month_last_day}",
                              "ga:deviceCategory==desktop")
    @page3_mobile = @analytics.page1(profile_id, "#{year_month_str}-#{'%02d' % 1}",
                              "#{year_month_str}-#{'%02d' % previous_1_month_last_day}",
                              "ga:deviceCategory!=desktop")

    year_month_str = year_month_pre1_str
    event_pre1 = @analytics.event_1(
      profile_id,
      "#{year_month_str}-01",
      "#{year_month_str}-#{'%02d' % previous_1_month_last_day}")
    year_month_str = year_month_pre2_str
    event_pre2 = @analytics.event_1(
      profile_id,
      "#{year_month_str}-01",
      "#{year_month_str}-#{'%02d' % previous_2_month_last_day}")

    @event1 = {pre1:{}, pre2:{}}
    event_pre1["rows"].each{|o| @event1[:pre1][o.first] = [o[1], o[2]]}
    event_pre2["rows"].each{|o| @event1[:pre2][o.first] = [o[1], o[2]]}


    year_month_str = year_month_pre1_str
    event_pre1 = @analytics.event_2(
      profile_id,
      "#{year_month_str}-01",
      "#{year_month_str}-#{'%02d' % previous_1_month_last_day}")
    year_month_str = year_month_pre2_str
    event_pre2 = @analytics.event_2(
      profile_id,
      "#{year_month_str}-01",
      "#{year_month_str}-#{'%02d' % previous_2_month_last_day}")

    @event_2_pre1 = {}
    event_pre1["rows"].each do |obj|
      @event_2_pre1[obj[0]] = [obj[1], obj[2]]
    end
    @event_2_pre2 = {}
    event_pre2["rows"].each do |obj|
      @event_2_pre2[obj[0]] = [obj[1], obj[2]]
    end

    year_month_str = year_month_pre1_str
    event_pre1 = @analytics.event_3(
      profile_id,
      "#{year_month_str}-01",
      "#{year_month_str}-#{'%02d' % previous_1_month_last_day}")
    year_month_str = year_month_pre2_str
    event_pre2 = @analytics.event_3(
      profile_id,
      "#{year_month_str}-01",
      "#{year_month_str}-#{'%02d' % previous_2_month_last_day}")

    @event_3_pre1 = {}
    event_pre1["rows"].each do |obj|
      @event_3_pre1[obj[0]] = [obj[1], obj[2]]
    end
    @event_3_pre2 = {}
    event_pre2["rows"].each do |obj|
      @event_3_pre2[obj[0]] = [obj[1], obj[2]]
    end

    year_month_str = year_month_pre1_str
    event_pre1 = @analytics.event_4(
      profile_id,
      "#{year_month_str}-01",
      "#{year_month_str}-#{'%02d' % previous_1_month_last_day}")
    year_month_str = year_month_pre2_str
    event_pre2 = @analytics.event_4(
      profile_id,
      "#{year_month_str}-01",
      "#{year_month_str}-#{'%02d' % previous_2_month_last_day}")

    @event_4_pre1 = {}
    event_pre1["rows"].each do |obj|
      @event_4_pre1[obj[0]] = [obj[1], obj[2]]
    end
    @event_4_pre2 = {}
    event_pre2["rows"].each do |obj|
      @event_4_pre2[obj[0]] = [obj[1], obj[2]]
    end

    year_month_str = year_month_pre1_str
    event_pre1 = @analytics.event_5(
      profile_id,
      "#{year_month_str}-01",
      "#{year_month_str}-#{'%02d' % previous_1_month_last_day}")
    event_pre1 = event_pre1["rows"]
    @event_5_pre1 = {}
    event_pre1.each do |obj|
      next if obj[1]=="全部"
      obj[1].gsub! "年", ""
      @event_5_pre1[obj[1]] = {} if @event_5_pre1[obj[1]].nil?
      @event_5_pre1[obj[1]][obj.first] = 0 if @event_5_pre1[obj[1]][obj.first].nil?
      @event_5_pre1[obj[1]][obj.first] += obj[2].to_i
    end

    year_month_str = year_month_pre1_str
    event_pre1 = @analytics.event_6(
      profile_id,
      "#{year_month_str}-01",
      "#{year_month_str}-#{'%02d' % previous_1_month_last_day}")
    event_pre1 = event_pre1["rows"]
    @event_6_pre1 = event_pre1

    year_month_str = year_month_pre1_str
    event_pre1 = @analytics.event_7(
      profile_id,
      "#{year_month_str}-01",
      "#{year_month_str}-#{'%02d' % previous_1_month_last_day}")
    event_pre1 = event_pre1["rows"]
    @event_7_pre1 = event_pre1

    year_month_str = year_month_pre1_str
    event_pre1 = @analytics.event_8(
      profile_id,
      "#{year_month_str}-01",
      "#{year_month_str}-#{'%02d' % previous_1_month_last_day}")
    event_pre1 = event_pre1["rows"]
    @event_8_pre1 = event_pre1

    year_month_str = year_month_pre1_str
    event_pre1 = @analytics.event_9(
      profile_id,
      "#{year_month_str}-01",
      "#{year_month_str}-#{'%02d' % previous_1_month_last_day}")
    event_pre1 = event_pre1["rows"]
    @event_9_pre1 = event_pre1

    event_pre1 = @analytics.event_10(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    event_pre1 = event_pre1["rows"]
    @event_10_pre1 = {}
    event_pre1.each do |obj|
      @event_10_pre1[obj[0]] = {} if @event_10_pre1[obj[0]].nil?
      @event_10_pre1[obj[0]] = [obj[1], obj[2]]
    end

    event_pre1 = @analytics.event_10(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    event_pre1 = event_pre1["rows"]
    @event_10_pre2 = {}
    event_pre1.each do |obj|
      @event_10_pre2[obj[0]] = {} if @event_10_pre2[obj[0]].nil?
      @event_10_pre2[obj[0]] = [obj[1], obj[2]]
    end

    event_pre1 = @analytics.event_11(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @event_11_pre1 = event_pre1["rows"]
    event_pre2 = @analytics.event_11(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    @event_11_pre2 = {}
    event_pre2["rows"].each do |obj|
      @event_11_pre2[obj.first] = obj.last
    end

    event_pre1 = @analytics.event_12(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @event_12_pre1 = event_pre1["rows"]
    event_pre2 = @analytics.event_12(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    @event_12_pre2 = {}
    event_pre2["rows"].each do |obj|
      @event_12_pre2[obj.first] = obj.last
    end

    event_pre1 = @analytics.event_13(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @event_13_pre1 = event_pre1["rows"]

    event_pre1 = @analytics.event_13(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    @event_13_pre2 = {}
    event_pre1["rows"].each do |obj|
      @event_13_pre2[obj[0]] = [obj[1], obj[2]]
    end

    event_pre1 = @analytics.event_14(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    event_pre1 = event_pre1["rows"] || {}
    event_pre1.map do |obj|
      obj[0] = obj[0].split(/:/).first
      obj[1] = obj[1].to_i
    end
    @event_14_pre1 = {}
    event_pre1.each do |obj|
      @event_14_pre1[obj.first] = 0 if @event_14_pre1[obj.first].nil?
      @event_14_pre1[obj.first] += obj.last
    end
    # @event_14_pre1.sort { |x, y| x.last <=> y.last }
    event_pre1 = @analytics.event_14(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    event_pre1 = event_pre1["rows"]
    if event_pre1.nil?
      event_pre1 = []
    else
      event_pre1.map do |obj|
        obj[0] = obj[0].split(/:/).first
        obj[1] = obj[1].to_i
      end
    end
    @event_14_pre2 = {}
    event_pre1.each do |obj|
      @event_14_pre2[obj.first] = 0 if @event_14_pre2[obj.first].nil?
      @event_14_pre2[obj.first] += obj.last
    end

    event_pre1 = @analytics.event_15(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @event_15_pre1 = event_pre1["rows"]

    event_pre1 = @analytics.event_15(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    event_pre1 = event_pre1["rows"]
    @event_15_pre2 = {}
    event_pre1.each do |obj|
      @event_15_pre2[obj.first] = [] if @event_15_pre2[obj.first].nil?
      @event_15_pre2[obj.first] = [obj[1], obj[2]]
    end

    event_pre1 = @analytics.event_16(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @event_16_pre1 = event_pre1["rows"]

    event_pre1 = @analytics.event_16(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    event_pre1 = event_pre1["rows"]
    @event_16_pre2 = {}
    event_pre1.each do |obj|
      @event_16_pre2[obj.first] = [] if @event_16_pre2[obj.first].nil?
      @event_16_pre2[obj.first] = [obj[1], obj[2]]
    end
  end

  private
  def turingdigital_only
    redirect_to root_path if current_user.nil?
    redirect_to root_path if current_user.email != "analytics@adup.com.tw"
  end
end
