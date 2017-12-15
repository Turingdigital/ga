class SstainanController < ApplicationController

  def index
    # current_user = User.find(38)# if !current_user
    @analytics = Analytics.new current_user
    profile_id = params[:profile_id] # "147896085" # 妳好南搞
    @profile_id = profile_id


    pre_month = Date.today.prev_month
    @pre_month_first_day = params["start_date"]|| Date.civil(pre_month.year, pre_month.month, 1).strftime('%F')
    @pre_month_last_day = params["end_date"]||Date.civil(pre_month.year, pre_month.month, -1).strftime('%F')

    all_data = []
    start_index = 1
    start_date = params["start_date"]||@pre_month_first_day
    end_date = params["end_date"]||@pre_month_last_day
    result = @analytics.sstainan(profile_id, start_date, end_date)
    pageview = @analytics.sstainan_pageview(profile_id, start_date, end_date)
    pageview = pageview["rows"]
    map = {}
    pageview.each {|p|
      map[p.first]= {pv: p[2], title: p[1], avgTimeOnPage: p[3]}
    }
    loop do
      break if result["rows"].nil?

      all_data.concat(result["rows"])
      break if result["rows"].size < 1000

      start_index += 1000
      result = @analytics.sstainan(profile_id, start_date, end_date, start_index)
    end
    all_data.each do |d|
      # byebug
      if map[d[1]]# && map[d[1]][d[0]]
        map[d[1]][d[0]] =d[2]
      end
      # break
    end

    @ok = map
    @ok.delete_if { |k, m|
      (k=~/customize_changeset_uuid|post_type|admin/) || m[:pv].nil?||m["25%"].nil?||m["50%"].nil?||m["75%"].nil?||m["100%"].nil? || (m[:pv].to_i==0)||(m["25%"].to_i==0)||(m["50%"].to_i==0)||(m["75%"].to_i==0)||(m["100%"].to_i==0)
    } if profile_id = "147896085"

    @ok.each {|k, m|
      m["25%"] = m[:pv] if m[:pv].to_i < m["25%"].to_i
      m["50%"] = m[:pv] if m[:pv].to_i < m["50%"].to_i
      m["75%"] = m[:pv] if m[:pv].to_i < m["75%"].to_i
      m["100%"] = m[:pv] if m[:pv].to_i < m["100%"].to_i
    }

    # csv = "列標籤,PV,25%,50%,75%,100%,總計,到50%的留存率,到75%的留存率\n"
    # map.each do |k, m|
    #   if m[:pv]&&m["25%"]&&m["50%"]&&m["75%"]&&m["100%"]
    #     csv << "#{k},#{m[:pv]},#{m["25%"]},#{m["50%"]},#{m["75%"]},#{m["100%"]}\n"
    #   end
    # end
    # byebug
  end

  def send_mail
    # current_user = User.find(38)# if !current_user
    @analytics = Analytics.new User.where(email: "analytics@turingdigital.com.tw").first
    profile_id = "147896085" # 妳好南搞
    @profile_id = profile_id


    pre_month = Date.today.prev_month
    @pre_month_first_day = 'yesterday'#params["start_date"]|| Date.civil(pre_month.year, pre_month.month, 1).strftime('%F')
    @pre_month_last_day = 'yesterday'#params["end_date"]||Date.civil(pre_month.year, pre_month.month, -1).strftime('%F')

    all_data = []
    start_index = 1
    start_date = params["start_date"]||@pre_month_first_day
    end_date = params["end_date"]||@pre_month_last_day
    result = @analytics.sstainan(profile_id, start_date, end_date)
    pageview = @analytics.sstainan_pageview(profile_id, start_date, end_date)
    pageview = pageview["rows"]
    map = {}
    pageview.each {|p|
      map[p.first]= {pv: p[2], title: p[1], avgTimeOnPage: p[3]}
    }
    loop do
      break if result["rows"].nil?

      all_data.concat(result["rows"])
      break if result["rows"].size < 1000

      start_index += 1000
      result = @analytics.sstainan(profile_id, start_date, end_date, start_index)
    end
    all_data.each do |d|
      # byebug
      if map[d[1]]# && map[d[1]][d[0]]
        map[d[1]][d[0]] =d[2]
      end
      # break
    end

    @ok = map
    @ok.delete_if { |k, m|
      (k=~/customize_changeset_uuid|post_type|admin/) || m[:pv].nil?||m["25%"].nil?||m["50%"].nil?||m["75%"].nil?||m["100%"].nil? || (m[:pv].to_i==0)||(m["25%"].to_i==0)||(m["50%"].to_i==0)||(m["75%"].to_i==0)||(m["100%"].to_i==0)
    } if profile_id = "147896085"

    @ok.each {|k, m|
      m["25%"] = m[:pv] if m[:pv].to_i < m["25%"].to_i
      m["50%"] = m[:pv] if m[:pv].to_i < m["50%"].to_i
      m["75%"] = m[:pv] if m[:pv].to_i < m["75%"].to_i
      m["100%"] = m[:pv] if m[:pv].to_i < m["100%"].to_i
    }

    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    i = 0
    sheet1.row(0).replace(%w(列標籤 PV Title 停留時間 25% 50% 75% 100% 總計 到50%的留存率 到75%的留存率))

    i = 1
    @ok.each {|k, v|
      sheet1.row(i).replace([k, v[:pv], v[:title],
          '%.2f' % v[:avgTimeOnPage].to_f,
          v["100%"],
          v["25%"], v["50%"], v["75%"],
          v["25%"].to_i+v["50%"].to_i+v["75%"].to_i+v["100%"].to_i,
          "#{'%.2f' % (v["50%"].to_f / v[:pv].to_f * 100)}%",
          "#{'%.2f' % (v["75%"].to_f / v[:pv].to_f * 100)}%"
        ],
      )
      i += 1
    }
    filename = "stainan_#{(Date.today-1).to_s}"
    book.write(Rails.root+"public/csv/#{filename}.xls")

    UserMailer.stainan(filename).deliver_now!
    render plain: "OK"
  end

  def download
    # byebug
    redirect_to :back #sstainan_path
    # send_data @users.to_csv, filename: "users-#{Date.today}.csv"
  end
end
