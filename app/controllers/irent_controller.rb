class IrentController < ApplicationController
  before_action :turingdigital_only

  def index
    @analytics = Analytics.new current_user
    profile_id = "106576725" #"23098605"

    today = DateTime.now
    previous_1_month = today << 1
    @previous_1_month = previous_1_month
    previous_1_month_last_day = Date.civil(previous_1_month.year, previous_1_month.month, -1).day
    previous_2_month = today << 2
    @previous_2_month = previous_2_month
    previous_2_month_last_day = Date.civil(previous_2_month.year, previous_2_month.month, -1).day

    year_month_pre1_str = "#{previous_1_month.year}-#{('%02d' % previous_1_month.month)}"
    year_month_pre2_str = "#{previous_2_month.year}-#{('%02d' % previous_2_month.month)}"

    day = 1
    @data_pre1_desktop = []
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
        "#{year_month_pre1_str}-#{'%02d' % day}",
        "#{year_month_pre1_str}-#{'%02d' % (n==4 ? previous_1_month_last_day : day+=5)}",
        %w(ga:deviceCategory!=desktop))
      day += 1
    end
    day = 1
    @data_pre2_mobile = []
    year_month_str = year_month_pre2_str
    5.times do |n|
      @data_pre2_mobile << @analytics.page1_1(
        profile_id,
        "#{year_month_pre2_str}-#{'%02d' % day}",
        "#{year_month_pre2_str}-#{'%02d' % (n==4 ? previous_2_month_last_day : day+=5)}",
        %w(ga:deviceCategory!=desktop))
      day += 1
    end
    day = 1
    @data_pre1_all = []
    year_month_str = year_month_pre1_str
    5.times do |n|
      @data_pre1_all << @analytics.page1_1(
        profile_id,
        "#{year_month_pre1_str}-#{'%02d' % day}",
        "#{year_month_pre1_str}-#{'%02d' % (n==4 ? previous_1_month_last_day : day+=5)}")
      day += 1
    end
    day = 1
    @data_pre2_all = []
    year_month_str = year_month_pre2_str
    5.times do |n|
      @data_pre2_all << @analytics.page1_1(
        profile_id,
        "#{year_month_pre2_str}-#{'%02d' % day}",
        "#{year_month_pre2_str}-#{'%02d' % (n==4 ? previous_2_month_last_day : day+=5)}")
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
    @page3_all = @analytics.page1(profile_id, "#{year_month_pre1_str}-#{'%02d' % 1}",
                              "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @page3_desktop = @analytics.page1(profile_id, "#{year_month_pre1_str}-#{'%02d' % 1}",
                              "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}",
                              "ga:deviceCategory==desktop")
    @page3_mobile = @analytics.page1(profile_id, "#{year_month_pre1_str}-#{'%02d' % 1}",
                              "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}",
                              "ga:deviceCategory!=desktop")

    event_pre1 = @analytics.irent_1(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @irent_1 = event_pre1["rows"]

    @irent_2_pre1 = @analytics.irent_2(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @irent_2_pre1 = @irent_2_pre1["rows"]
    irent_2_pre2 = @analytics.irent_2(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    irent_2_pre2 = irent_2_pre2["rows"]
    @irent_2_pre2 = {}
    irent_2_pre2.each do |obj|
      @irent_2_pre2[obj.first] = [] if @irent_2_pre2[obj.first].nil?
      @irent_2_pre2[obj.first] = [obj[1], obj[2]]
    end

    @irent_3_pre1 = @analytics.irent_3(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @irent_3_pre1 = @irent_3_pre1["rows"]
    irent_2_pre2 = @analytics.irent_3(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    irent_2_pre2 = irent_2_pre2["rows"]
    @irent_3_pre2 = {}
    irent_2_pre2.each do |obj|
      @irent_3_pre2[obj.first] = [] if @irent_3_pre2[obj.first].nil?
      @irent_3_pre2[obj.first] = [obj[1], obj[2]]
    end

    @irent_4_pre1 = @analytics.irent_4(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @irent_4_pre1 = @irent_4_pre1["rows"]
    @irent_5_pre1 = @analytics.irent_5(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @irent_5_pre1 = @irent_5_pre1["rows"]
    @irent_6_pre1 = @analytics.irent_6(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @irent_6_pre1 = @irent_6_pre1["rows"]
    @irent_7_pre1 = @analytics.irent_7(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @irent_7_pre1 = @irent_7_pre1["rows"]

    irent_8_pre1 = @analytics.irent_8(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    irent_8_pre1 = irent_8_pre1["rows"]
    @irent_8_pre1 = {}
    irent_8_pre1.each do |obj|
      @irent_8_pre1[obj[0]] = obj[1]
    end
    irent_8_pre2 = @analytics.irent_8(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    irent_8_pre2 = irent_8_pre2["rows"]
    @irent_8_pre2 = {}
    irent_8_pre2.each do |obj|
      @irent_8_pre2[obj[0]] = obj[1]
    end

    irent_9_pre1 = @analytics.irent_9(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    irent_9_pre1 = irent_9_pre1["rows"]
    @irent_9_pre1 = {}
    irent_9_pre1.each do |obj|
      @irent_9_pre1[obj.first] = obj.last
    end

    irent_10_pre1 = @analytics.irent_10(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    irent_10_pre1 = irent_10_pre1["rows"]
    @irent_10_pre1 = {}
    irent_10_pre1.each do |obj|
      @irent_10_pre1[obj.first] = obj.last
    end

    irent_11_pre1 = @analytics.irent_11(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @irent_11_pre1_totalEvents = irent_11_pre1["totals_for_all_results"]["ga:totalEvents"]
    irent_11_pre1 = irent_11_pre1["rows"]
    @irent_11_pre1 = {}
    irent_11_pre1.each do |obj|
      @irent_11_pre1[obj.first] = obj.last
    end

    irent_12_pre1 = @analytics.irent_12(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @irent_12_pre1_totalEvents = irent_12_pre1["totals_for_all_results"]["ga:totalEvents"]
    irent_12_pre1 = irent_12_pre1["rows"]
    @irent_12_pre1 = {}
    irent_12_pre1.each do |obj|
      @irent_12_pre1[obj.first] = obj.last
    end

    irent_13_pre1 = @analytics.irent_13(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @irent_13_pre1 = irent_13_pre1["rows"]
    irent_13_1_pre1 = @analytics.irent_13_1(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @irent_13_1_pre1_totalEvents = irent_13_1_pre1["totals_for_all_results"]["ga:totalEvents"]
    irent_13_1_pre1 = irent_13_1_pre1["rows"]
    @irent_13_1_pre1 = {}
    irent_13_1_pre1.each do |obj|
      @irent_13_1_pre1[obj.first] = obj.last
    end

    irent_14_pre1 = @analytics.irent_14(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    irent_14_pre1 = irent_14_pre1["rows"]
    @irent_14_pre1 = {}
    irent_14_pre1.each {|obj|
      @irent_14_pre1[obj[0]] = {} if @irent_14_pre1[obj[0]].nil?
      @irent_14_pre1[obj[0]][obj[1]] = {} if @irent_14_pre1[obj[0]][obj[1]].nil?
      @irent_14_pre1[obj[0]][obj[1]][obj[2]] = {} if @irent_14_pre1[obj[0]][obj[2]].nil?
      @irent_14_pre1[obj[0]][obj[1]][obj[2]] = obj[3].to_i
    }
    irent_14_1_pre1 = @analytics.irent_14_1(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    irent_14_1_pre1 = irent_14_1_pre1["rows"]
    @irent_14_1_pre1 = {}
    irent_14_1_pre1.each {|obj|
      @irent_14_1_pre1[obj[0]] = {} if @irent_14_1_pre1[obj[0]].nil?
      @irent_14_1_pre1[obj[0]][obj[1]] = {} if @irent_14_1_pre1[obj[0]][obj[1]].nil?
      @irent_14_1_pre1[obj[0]][obj[1]][obj[2]] = {} if @irent_14_1_pre1[obj[0]][obj[2]].nil?
      @irent_14_1_pre1[obj[0]][obj[1]][obj[2]] = obj[3].to_i
    }

    @irent_14_pre1_total = {
      sessions: {},
      events: {}
    }

    @irent_14_pre1.each {|k, v|
      @irent_14_pre1_total[:sessions][k] = {"total" => 0} if @irent_14_pre1_total[:sessions][k].nil?
      v.each {|k1, v1|
        @irent_14_pre1_total[:sessions][k][k1] = 0 if @irent_14_pre1_total[:sessions][k][k1].nil?
        v1.each {|k2, v2|
          @irent_14_pre1_total[:sessions][k]["total"] += v2
          @irent_14_pre1_total[:sessions][k][k1] += v2
        }
      }
    }

    @irent_14_1_pre1.each {|k, v|
      @irent_14_pre1_total[:events][k] = {"total" => 0} if @irent_14_pre1_total[:events][k].nil?
      v.each {|k1, v1|
        @irent_14_pre1_total[:events][k][k1] = 0 if @irent_14_pre1_total[:events][k][k1].nil?
        v1.each {|k2, v2|
          @irent_14_pre1_total[:events][k]["total"] += v2
          @irent_14_pre1_total[:events][k][k1] += v2
        }
      }
    }


    ######################
    # 我要租車與活動網站表現 #
    ######################
    profile_id = "124432320" #"23098605"

    day = 1
    @data_2_pre1_desktop = []
    5.times do |n|
      @data_2_pre1_desktop << @analytics.page1_1(
        profile_id,
        "#{year_month_pre1_str}-#{'%02d' % day}",
        "#{year_month_pre1_str}-#{'%02d' % (n==4 ? previous_1_month_last_day : day+=5)}",
        %w(ga:deviceCategory==desktop))
      day += 1
    end
    day = 1
    @data_2_pre2_desktop = []
    year_month_pre2_str = "#{previous_2_month.year}-#{('%02d' % previous_2_month.month)}"
    5.times do |n|
      @data_2_pre2_desktop << @analytics.page1_1(
        profile_id,
        "#{year_month_pre2_str}-#{'%02d' % day}",
        "#{year_month_pre2_str}-#{'%02d' % (n==4 ? previous_2_month_last_day : day+=5)}",
        %w(ga:deviceCategory==desktop))
      day += 1
    end
    day = 1
    @data_2_pre1_mobile = []
    year_month_str = year_month_pre1_str
    5.times do |n|
      @data_2_pre1_mobile << @analytics.page1_1(
        profile_id,
        "#{year_month_pre1_str}-#{'%02d' % day}",
        "#{year_month_pre1_str}-#{'%02d' % (n==4 ? previous_1_month_last_day : day+=5)}",
        %w(ga:deviceCategory!=desktop))
      day += 1
    end
    day = 1
    @data_2_pre2_mobile = []
    year_month_str = year_month_pre2_str
    5.times do |n|
      @data_2_pre2_mobile << @analytics.page1_1(
        profile_id,
        "#{year_month_pre2_str}-#{'%02d' % day}",
        "#{year_month_pre2_str}-#{'%02d' % (n==4 ? previous_2_month_last_day : day+=5)}",
        %w(ga:deviceCategory!=desktop))
      day += 1
    end
    day = 1
    @data_2_pre1_all = []
    year_month_str = year_month_pre1_str
    5.times do |n|
      @data_2_pre1_all << @analytics.page1_1(
        profile_id,
        "#{year_month_pre1_str}-#{'%02d' % day}",
        "#{year_month_pre1_str}-#{'%02d' % (n==4 ? previous_1_month_last_day : day+=5)}")
      day += 1
    end
    day = 1
    @data_2_pre2_all = []
    year_month_str = year_month_pre2_str
    5.times do |n|
      @data_2_pre2_all << @analytics.page1_1(
        profile_id,
        "#{year_month_pre2_str}-#{'%02d' % day}",
        "#{year_month_pre2_str}-#{'%02d' % (n==4 ? previous_2_month_last_day : day+=5)}")
      day += 1
    end

    @basic_2_data = {
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

    @data_2_pre1_desktop.each do |d|
       @basic_2_data[:pre1][:desktop][:users] << d["rows"][0][0]
       @basic_2_data[:pre1][:desktop][:sessions] << d["rows"][0][1]
    end
    @data_2_pre2_desktop.each do |d|
       @basic_2_data[:pre2][:desktop][:users] << d["rows"][0][0]
       @basic_2_data[:pre2][:desktop][:sessions] << d["rows"][0][1]
    end
    @data_2_pre1_mobile.each do |d|
       @basic_2_data[:pre1][:mobile][:users] << d["rows"][0][0]
       @basic_2_data[:pre1][:mobile][:sessions] << d["rows"][0][1]
    end
    @data_2_pre2_mobile.each do |d|
       @basic_2_data[:pre2][:mobile][:users] << d["rows"][0][0]
       @basic_2_data[:pre2][:mobile][:sessions] << d["rows"][0][1]
    end
    @data_2_pre1_all.each do |d|
       @basic_2_data[:pre1][:all][:users] << d["rows"][0][0]
       @basic_2_data[:pre1][:all][:sessions] << d["rows"][0][1]
    end
    @data_2_pre2_all.each do |d|
       @basic_2_data[:pre2][:all][:users] << d["rows"][0][0]
       @basic_2_data[:pre2][:all][:sessions] << d["rows"][0][1]
    end

    year_month_str = year_month_pre1_str
    @page3_2_all = @analytics.page1(profile_id, "#{year_month_pre1_str}-#{'%02d' % 1}",
                              "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @page3_2_desktop = @analytics.page1(profile_id, "#{year_month_pre1_str}-#{'%02d' % 1}",
                              "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}",
                              "ga:deviceCategory==desktop")
    @page3_2_mobile = @analytics.page1(profile_id, "#{year_month_pre1_str}-#{'%02d' % 1}",
                              "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}",
                              "ga:deviceCategory!=desktop")

    irent_15_pre1 = @analytics.irent_15(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @irent_15_pre1 = irent_15_pre1["rows"]
    irent_15_pre2 = @analytics.irent_15(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    irent_15_pre2 = irent_15_pre2["rows"]
    @irent_15_pre2 = {}
    irent_15_pre2.each { |obj|@irent_15_pre2[obj[0]] = obj[1] }

    irent_16_pre1 = @analytics.irent_16(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @irent_16_pre1 = irent_16_pre1["rows"]
    irent_16_pre2 = @analytics.irent_16(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    irent_16_pre2 = irent_16_pre2["rows"]
    @irent_16_pre2 = {}
    irent_16_pre2.each { |obj|@irent_16_pre2[obj[0]] = obj[1] }

    irent_17_pre1 = @analytics.irent_17(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @irent_17_pre1 = irent_17_pre1["rows"]
    irent_17_pre2 = @analytics.irent_17(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    irent_17_pre2 = irent_17_pre2["rows"]
    @irent_17_pre2 = {}
    irent_17_pre2.each { |obj|@irent_17_pre2[obj[0]] = obj[1] }

    irent_18_pre1 = @analytics.irent_18(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @irent_18_pre1 = irent_18_pre1["rows"]
    irent_18_pre2 = @analytics.irent_18(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    irent_18_pre2 = irent_18_pre2["rows"]
    @irent_18_pre2 = {}
    irent_18_pre2.each { |obj|@irent_18_pre2[obj[0]] = obj[1] }

    irent_19_pre1 = @analytics.irent_19(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @irent_19_pre1 = irent_19_pre1["rows"]
    irent_19_pre2 = @analytics.irent_19(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    irent_19_pre2 = irent_19_pre2["rows"]
    @irent_19_pre2 = {}
    irent_19_pre2.each { |obj|@irent_19_pre2[obj[0]] = obj[1] }

    irent_20_pre1 = @analytics.irent_20(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @irent_20_pre1 = irent_20_pre1["rows"]
    irent_20_pre2 = @analytics.irent_20(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    irent_20_pre2 = irent_20_pre2["rows"]
    @irent_20_pre2 = {}
    irent_20_pre2.each { |obj|@irent_20_pre2[obj[0]] = obj[1] }

    irent_21_pre1 = @analytics.irent_21(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    irent_21_pre1 = irent_21_pre1["rows"]
    @irent_21_pre1 = {}
    irent_21_pre1.each { |obj|@irent_21_pre1[obj[0]] = obj[1] }
    irent_21_pre2 = @analytics.irent_21(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    irent_21_pre2 = irent_21_pre2["rows"]
    @irent_21_pre2 = {}
    irent_21_pre2.each { |obj|@irent_21_pre2[obj[0]] = obj[1] }

    irent_21_2_pre1 = @analytics.irent_21_2(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @irent_21_2_pre1 = irent_21_2_pre1["rows"]
    irent_21_2_pre2 = @analytics.irent_21_2(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    @irent_21_2_pre2 = irent_21_2_pre2["rows"]

  end

  private
  def turingdigital_only
    redirect_to root_path if current_user.nil?
    redirect_to root_path if current_user.email != "analytics@adup.com.tw"
  end
end
