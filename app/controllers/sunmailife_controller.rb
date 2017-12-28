class SunmailifeController < ApplicationController
  def index
    # current_user = User.find(38)# if !current_user
    @analytics = Analytics.new current_user
    profile_id = params[:profile_id] || "147896085" # 妳好南搞
    @profile_id = profile_id


    pre_month = Date.today.prev_month
    @pre_month_first_day = params["start_date"]|| Date.civil(pre_month.year, pre_month.month, 1).strftime('%F')
    @pre_month_last_day = params["end_date"]||Date.civil(pre_month.year, pre_month.month, -1).strftime('%F')

    all_data = []
    start_index = 1
    start_date = params["start_date"]||@pre_month_first_day
    end_date = params["end_date"]||@pre_month_last_day

    pageview = @analytics.sstainan_pageview(profile_id, start_date, end_date)
    pageview = pageview["rows"]
    map = {}
    pageview.each {|p|
      map[p.first] = {} if map[p.first].nil?
      map[p.first][p[1]] = {pv: p[2], title: p[1], avgTimeOnPage: p[3]}
    }

    result = @analytics.sunamilife(profile_id, start_date, end_date)
    loop do
      break if result["rows"].nil?

      all_data.concat(result["rows"])
      break if result["rows"].size < 1000

      start_index += 1000
      result = @analytics.sunamilife(profile_id, start_date, end_date, start_index)
    end

    all_data.each do |d|
      if map[d[1]] && map[d[1]][d[2]] # && map[d[1]][d[0]]
        map[d[1]][d[2]][d[0]] = d.last
      end
      # break
    end

    @ok = map
    @ok.each {|k, m|
      m.each {|k1, m1|
        m1["25%"] = m1[:pv] if m1[:pv].to_i < m1["25%"].to_i
        m1["50%"] = m1[:pv] if m1[:pv].to_i < m1["50%"].to_i
        m1["75%"] = m1[:pv] if m1[:pv].to_i < m1["75%"].to_i
        m1["100%"] = m1[:pv] if m1[:pv].to_i < m1["100%"].to_i
        @ok[k].delete(k1) if @ok[k][k1]["25%"].nil?
      }
      @ok.delete(k) if @ok[k].empty?
    }
    session[:ok] = @ok
  end

  def download
    # byebug
    # redirect_to :back #sstainan_path
    # send_data @users.to_csv, filename: "users-#{Date.today}.csv"
    @ok = session[:ok]
    ary = [["列標籤", "PV", "Title", "停留時間", "25%", "50%", "75%", "100%", "總計", "到50%的留存率", "到75%的留存率"]]
    @ok.each do |k, m|
      m.each do |k1, m1|
        ary << [
          k,
          m1[:pv],
          m1[:title],
          '%.2f' % m1[:avgTimeOnPage].to_f,
          m1["25%"]||0,
          m1["50%"]||0,
          m1["75%"]||0,
          m1["100%"]||0,

          m1["25%"].to_i+m1["50%"].to_i+m1["75%"].to_i+m1["100%"].to_i,
          m1[:pv]==0 ? 0 : '%.2f' % (m1["50%"].to_f / m1[:pv].to_f * 100),
          m1[:pv]==0 ? 0 : '%.2f' % (m1["75%"].to_f / m1[:pv].to_f * 100),
        ]
      end
    end

    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    i = 0
    ary.each do |row|
      sheet1.row(i).replace(row)
      i += 1
    end

    @time_now = Time.now.to_f
    filename = Rails.root+"public/csv/result#{@time_now}.xls"
    book.write(filename)
    redirect_to "/csv/result#{@time_now}.xls"
  end
end
