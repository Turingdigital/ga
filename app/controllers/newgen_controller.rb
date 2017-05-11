class NewgenController < ApplicationController
  def index
    @analytics = Newgen.new current_user
    profile_id = "127880814" #"23098605"

    today = DateTime.now
    y1 = params[:y1]
    m1 = params[:m1]
    previous_2_month = (y1&&m1) ? DateTime.new(y1.to_i, m1.to_i) : today << 2

    y2 = params[:y2]
    m2 = params[:m2]
    previous_1_month = (y2&&m2) ? DateTime.new(y2.to_i, m2.to_i) : previous_2_month >> 1

    @previous_2_month = previous_2_month
    previous_2_month_last_day = Date.civil(previous_2_month.year, previous_2_month.month, -1).day

    @previous_1_month = previous_1_month
    previous_1_month_last_day = Date.civil(previous_1_month.year, previous_1_month.month, -1).day

    year_month_pre1_str = "#{previous_1_month.year}-#{('%02d' % previous_1_month.month)}"
    year_month_pre2_str = "#{previous_2_month.year}-#{('%02d' % previous_2_month.month)}"

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
      },
      pre2:{
        all: {sessions:[], users:[]},
      },
    }

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



    @newgen_1_pre1 = @analytics.newgen_1(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @newgen_1_pre1 = @newgen_1_pre1["rows"]
    newgen_1_pre2 = @analytics.newgen_1(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    newgen_1_pre2 = newgen_1_pre2["rows"]
    @newgen_1_pre2 = {}
    newgen_1_pre2.each do |obj|
      @newgen_1_pre2[obj.first] = [] if @newgen_1_pre2[obj.first].nil?
      @newgen_1_pre2[obj.first] = [obj[1], obj[2]]
    end

    @newgen_2 = @analytics.newgen_2(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @newgen_2 = @newgen_2["rows"]

    @newgen_2_pre2 = @analytics.newgen_2_pre2(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    @newgen_2_pre2 = @newgen_2_pre2["rows"]
    @newgen_2_pre2 = Hash[*@newgen_2_pre2.flatten]

    @newgen_3 = @analytics.newgen_3(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @newgen_3 = @newgen_3["rows"]
    @newgen_3 = Hash[*@newgen_3.flatten]

    @newgen_4 = @analytics.newgen_4(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @newgen_4 = @newgen_4["rows"]

    @newgen_4_pre2 = @analytics.newgen_4_pre2(
      profile_id,
      "#{year_month_pre2_str}-01",
      "#{year_month_pre2_str}-#{'%02d' % previous_2_month_last_day}")
    @newgen_4_pre2 = @newgen_4_pre2["rows"]
    @newgen_4_pre2 = Hash[*@newgen_4_pre2.flatten]

    @newgen_5 = @analytics.newgen_5(
      profile_id,
      "#{year_month_pre1_str}-01",
      "#{year_month_pre1_str}-#{'%02d' % previous_1_month_last_day}")
    @newgen_5 = @newgen_5["rows"]
    @newgen_5 = Hash[*@newgen_5.flatten]
  end
end
