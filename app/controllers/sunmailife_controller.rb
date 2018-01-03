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

    pageview = @analytics.sstainan_pageview(profile_id, start_date, end_date, 1)
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
        # byebug if d[1]=='/index.php?s=confirm&property=twtai31188&confirmation=dEuR9rx5k810TwSN&bh=645617f6e2137c83bd1a422549d95dcac396e27a4904ba27193978cba9994edd7c8c5427df576cbc7b1593a5602336f851af3058c2a42c6827ef733ee2b964a7&arrival=2017-12-31&departure=2018-01-01&adults1=2&adults2=2&children1=0&childrenAges1=&children2=0&rooms=2&locale=zh_Hant_HK&currency=TWD&stid=glkka0txo&showPromotions=3&language=zh&Hotelnames=ASIATWHTLSNTLifeHote&hname=ASIATWHTLSNTLifeHote&arrivalDateValue=2017-12-31&frommonth=12&fromday=31&fromyear=2017&departureDateValue=2018-01-01&tomonth=01&today=01&toyear=2018&adulteresa=2&nbAdultsValue=2&redir=BIZ-so5523q0o4&rt=1514634948'
      end
      # break
    end
# @ok['/index.php?s=confirm&property=twtai31188&confirmation=dEuR9rx5k810TwSN&bh=645617f6e2137c83bd1a422549d95dcac396e27a4904ba27193978cba9994edd7c8c5427df576cbc7b1593a5602336f851af3058c2a42c6827ef733ee2b964a7&arrival=2017-12-31&departure=2018-01-01&adults1=2&adults2=2&children1=0&childrenAges1=&children2=0&rooms=2&locale=zh_Hant_HK&currency=TWD&stid=glkka0txo&showPromotions=3&language=zh&Hotelnames=ASIATWHTLSNTLifeHote&hname=ASIATWHTLSNTLifeHote&arrivalDateValue=2017-12-31&frommonth=12&fromday=31&fromyear=2017&departureDateValue=2018-01-01&tomonth=01&today=01&toyear=2018&adulteresa=2&nbAdultsValue=2&redir=BIZ-so5523q0o4&rt=1514634948']
    @ok = map
    # byebug

    @ok.each {|k, m|
      m.each {|k1, m1|
        if @ok[k][k1]["25%"].nil?
          @ok[k].delete(k1)
          next
        end
        if m1[:pv]=='0'
          @ok[k].delete(k1)
          next
        end
        m1["25%"] = m1[:pv] if m1[:pv].to_i < m1["25%"].to_i
        m1["50%"] = m1[:pv] if m1[:pv].to_i < m1["50%"].to_i
        m1["75%"] = m1[:pv] if m1[:pv].to_i < m1["75%"].to_i
        m1["100%"] = m1[:pv] if m1[:pv].to_i < m1["100%"].to_i
        @ok[k].delete(k1) if @ok[k][k1]["25%"].nil?
      }
      @ok.delete(k) if @ok[k].empty?
    }
    # byebug
    # session[:ok] = @ok

    session[:ok] = save_result(@ok)
  end

  def download

    redirect_to session[:ok]

    # byebug
    # redirect_to :back #sstainan_path
    # send_data @users.to_csv, filename: "users-#{Date.today}.csv"


    # @ok = session[:ok]
    # ary = [["列標籤", "PV", "Title", "停留時間", "25%", "50%", "75%", "100%", "總計", "到50%的留存率", "到75%的留存率"]]
    # @ok.each do |k, m|
    #   m.each do |k1, m1|
    #     ary << [
    #       k,
    #       m1[:pv],
    #       m1[:title],
    #       '%.2f' % m1[:avgTimeOnPage].to_f,
    #       m1["25%"]||0,
    #       m1["50%"]||0,
    #       m1["75%"]||0,
    #       m1["100%"]||0,
    #
    #       m1["25%"].to_i+m1["50%"].to_i+m1["75%"].to_i+m1["100%"].to_i,
    #       m1[:pv]=="0" ? 0 : '%.2f' % (m1["50%"].to_f / m1[:pv].to_f * 100),
    #       m1[:pv]=="0" ? 0 : '%.2f' % (m1["75%"].to_f / m1[:pv].to_f * 100),
    #     ]
    #   end
    # end
    #
    # book = Spreadsheet::Workbook.new
    # sheet1 = book.create_worksheet
    #
    # i = 0
    # ary.each do |row|
    #   sheet1.row(i).replace(row)
    #   i += 1
    # end
    #
    # @time_now = Time.now.to_f
    # filename = Rails.root+"public/csv/result#{@time_now}.xls"
    # book.write(filename)
    # redirect_to "/csv/result#{@time_now}.xls"
  end

  private
  def save_result data
    @ok = data
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
          m1[:pv]=="0" ? 0 : '%.2f' % (m1["50%"].to_f / m1[:pv].to_f * 100),
          m1[:pv]=="0" ? 0 : '%.2f' % (m1["75%"].to_f / m1[:pv].to_f * 100),
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
    return "/csv/result#{@time_now}.xls"
  end
end
