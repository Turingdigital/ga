class WelcomeController < ApplicationController
  layout false

  def index
    redirect_to user_user_path(current_user) if user_signed_in?
       #.account_summary if current_user.account_summary
  end

  # 志光
  def jr_guang
    u = User.where(email: 'analytics@turingdigital.com.tw').first
    ana = Analytics.new u
    profile_id = '170698515'
    start_date, end_date = "yesterday", "yesterday" # "2018-02-01", "2018-03-21"
    result = ana.jr_guang(profile_id , start_date, end_date)

    all_data = []
    start_index = 1
    loop do
      break if result["rows"].nil?

      all_data.concat(result["rows"])
      break if result["rows"].size < 1000

      start_index += 1000
      result = ana.jr_guang(profile_id, start_date, end_date, start_index)
    end
    cookies = {}
    all_data.each {|ck|
      cookies[ck[3]] = {form_name: []} if cookies[ck[3]].nil?
      cookies[ck[3]][:form_name] << ck[0] # = [] if cookies[ck[3]][ck[0]].nil?
      cookies[ck[3]][ck[1]] = [] if cookies[ck[3]][ck[1]].nil?
      cookies[ck[3]][ck[1]] << ck[2]

      cookies[ck[3]][:form_name].uniq!
      cookies[ck[3]][ck[1]].uniq!
    }

    client_ids = cookies.keys
    client_ids.delete("false")
    user_infos = {}
    client_ids.each_slice(3) {|arr|
      break if arr.nil? || arr.empty?
      rr = ana.jr_guang_client_id(arr)
      begin
        rr["rows"].each {|usifo|
          user_infos[usifo[3]] = {} if user_infos[usifo[3]].nil?
          user_infos[usifo[3]][usifo[1]] = [] if user_infos[usifo[3]][usifo[1]].nil?
          user_infos[usifo[3]][usifo[1]] << usifo[2]
        } unless rr["rows"].nil?
      rescue
        byebug if Rails.env == "development"
      end

    }
    user_infos.each {|k, v|
      v.each {|k2, v2|
        cookies[k][k2] = v2
      }
    }

    # byebug if Rails.env == "development"
    # cookies.keys.delete # 所有的client_ids

# https://eye-www.amego.tw/cart_success.php?oid=1118032600011
    excel_array = {
      "失敗表單"=>[["ClientId","表單名稱","USER_ID","班別","狀態","中文姓名(必填)_輸入", "行動電話(必填)_輸入", "Email(必填)_輸入",
      "居住縣市_輸入", "居住地區_輸入", "地址_輸入", "可連絡時間_輸入", "洽詢班級_輸入",
      "洽詢細節說明(必填)_輸入", "個資保護聲明點擊", "立即提交點擊"]],
      "表單列表" => [["列標籤","資訊表單","USER_ID","班別","狀態"]]
    }
    cookies.each{|k, v|
      _end = false
      row_cnt = 0
      until _end
        _end = true
        row = [k]
        # row2 = [k]
        [:form_name, "UserID", "inclass", "state","中文姓名(必填)_輸入", "行動電話(必填)_輸入", "Email(必填)_輸入",
          "居住縣市_輸入", "居住地區_輸入", "地址_輸入", "可連絡時間_輸入", "洽詢班級_輸入",
          "洽詢細節說明(必填)_輸入", "個資保護聲明點擊", "立即提交點擊"].each{|field|

          # if ["UserID", "inclass", "state"].include?(field)
          #   row << v[field]
          #   next
          # end

          if v[field].nil?
            row << ""
          elsif v[field][row_cnt]
            row << v[field][row_cnt]
            _end = false
          else
            row << ""
          end
        }
        row_cnt += 1
        excel_array["失敗表單"] << row unless _end
        # excel_array["表單列表"] << row2 if k!='false'
      end
    }

    cookies.each{|k, v|
      _end = false
      row_cnt = 0
      until _end
        _end = true
        row = [k]
        [:form_name, "UserID", "inclass", "state"].each{|field|
          if v[field].nil?
            row << ""
          elsif v[field][row_cnt]
            row << v[field][row_cnt]
            _end = false
          else
            row << ""
          end
        }
        row_cnt += 1
        excel_array["表單列表"] << row unless _end
        # excel_array["表單列表"] << row2 if k!='false'
      end
    }

    filename = "public_#{DateTime.now.to_i}.xls"
    write_xls filename, excel_array
    redirect_to "/xls/#{filename}"
    # @excel_array = excel_array
    # ary = mj["rows"]
    # ary.find_all {|ay|
    #   ay[0]=="確認點擊"
    # }.map {|ay| ay[2]}.each{|_id|
    #   ary.delete_if {|ay| ay[2]==_id||ay[0]=="設定密碼輸入"}}
    # # ary.each {|ay| puts "#{ay[2]},會員註冊,#{ay[0]},#{ay[1]},#{ay[3]}"}
    #
    # ic = Iconv.new("big5", "utf-8")
    # date_str = (Date.today-1).to_s
    # filename = "myjapan_#{date_str}"
    # CSV.open(Rails.root+"public/csv/#{filename}.csv", "wb", encoding: 'BIG5') do |csv|
    #   csv << ["Client ID", "事件類別", "事件動作", "活動標籤", "事件總數"].map {|str| ic.iconv(str)}
    #   ary.each {|ay|
    #     csv << [ay[2],ic.iconv("會員註冊"),ic.iconv(ay[0]),ic.iconv(ay[1]),ay[3]]
    #   }
    # end

    # UserMailer.notify_comment(filename, date_str).deliver_now!
  end

  def myjapan_auto
    u = User.where(email: 'analytics@turingdigital.com.tw').first
    ana = Analytics.new u
    mj = ana.myjapanHK_auto('96435422')
    ary = mj["rows"]
    ary.find_all {|ay|
      ay[0]=="確認點擊"
    }.map {|ay| ay[2]}.each{|_id|
      ary.delete_if {|ay| ay[2]==_id||ay[0]=="設定密碼輸入"}}
    # ary.each {|ay| puts "#{ay[2]},會員註冊,#{ay[0]},#{ay[1]},#{ay[3]}"}

    ic = Iconv.new("big5", "utf-8")
    date_str = (Date.today-1).to_s
    filename = "myjapan_#{date_str}"
    CSV.open(Rails.root+"public/csv/#{filename}.csv", "wb", encoding: 'BIG5') do |csv|
      csv << ["Client ID", "事件類別", "事件動作", "活動標籤", "事件總數"].map {|str| ic.iconv(str)}
      ary.each {|ay|
        csv << [ay[2],ic.iconv("會員註冊"),ic.iconv(ay[0]),ic.iconv(ay[1]),ay[3]]
      }
    end

    UserMailer.notify_comment(filename, date_str).deliver_now!
  end

  def myday_b01
    u = User.where(email: 'analytics@turingdigital.com.tw').first
    ana = Analytics.new u
    # start_date = prior_sunday(Date.today).strftime('%F')
    end_date_date = prior_saturday(Date.today)#.strftime('%F')
    start_date_date = end_date_date-6
    start_date = start_date_date.strftime('%F')
    end_date = end_date_date.strftime('%F')

    profile_id = '7525809'
    result = ana.myday_b01(profile_id, start_date, end_date)
    all_data = []
    start_index = 1
    loop do
      break if result["rows"].nil?

      all_data.concat(result["rows"])
      break if result["rows"].size < 1000

      start_index += 1000
      result = ana.myday_b01(profile_id, start_date, end_date, start_index)
    end

    # ary = mj["rows"]
    report = {}
    # sum = {}
    all_data.each do |arr|
      report[arr[2]] = {} if report[arr[2]].nil?
      # sum[arr[0]] = 0 if sum[arr[0]].nil?
      # ["勾選欄位:convstore_get", "OFF", "108533710.1514313304", "1", "1"]
      report[arr[2]][arr[0]] = arr[1]
      # sum[arr[0]] += arr[-1].to_i
    end
    # filename = (save_result report, sum, start_date, end_date)
    date_str = "#{start_date_date.strftime('%m_%d')}~#{end_date_date.strftime('%m_%d')}"
    filename = (save_result report, date_str) #, start_date, end_date)
    UserMailer.myday_b01(filename, date_str).deliver_now!
  end

  private
  # def save_result data, sum, start_date, end_date
  def save_result data, date_str # start_date, end_date
    ary = [["加總 - 不重複事件", "欄標籤"],
           [
             "列標籤",
             "勾選欄位:convstore_get",
             "編輯欄位:address",
             "編輯欄位:area",
             "編輯欄位:check_password",
             "編輯欄位:email",
             "編輯欄位:mobile",
             "編輯欄位:name",
             "編輯欄位:password",
             "編輯欄位:phone",
             "編輯欄位:q",
             "編輯欄位:recommend_code",
             "選擇欄位:county",
             "選擇欄位:day",
             "選擇欄位:district",
             "選擇欄位:month",
             "選擇欄位:sex",
             "選擇欄位:year",
           ]
          ]
    data.each do |k, m|
      ary << [
        k,
        m["勾選欄位:convstore_get"].nil? ? "":m["勾選欄位:convstore_get"],
        m["編輯欄位:address"].nil? ? "":m["編輯欄位:address"],
        m["編輯欄位:area"].nil? ? "":m["編輯欄位:area"],
        m["編輯欄位:check_password"].nil? ? "":m["編輯欄位:check_password"],
        m["編輯欄位:email"].nil? ? "":m["編輯欄位:email"],
        m["編輯欄位:mobile"].nil? ? "":m["編輯欄位:mobile"],
        m["編輯欄位:name"].nil? ? "":m["編輯欄位:name"],
        m["編輯欄位:password"].nil? ? "":m["編輯欄位:password"],
        m["編輯欄位:phone"].nil? ? "":m["編輯欄位:phone"],
        m["編輯欄位:q"].nil? ? "":m["編輯欄位:q"],
        m["編輯欄位:recommend_code"].nil? ? "":m["編輯欄位:recommend_code"],
        m["選擇欄位:county"].nil? ? "":m["選擇欄位:county"],
        m["選擇欄位:day"].nil? ? "":m["選擇欄位:day"],
        m["選擇欄位:district"].nil? ? "":m["選擇欄位:district"],
        m["選擇欄位:month"].nil? ? "":m["選擇欄位:month"],
        m["選擇欄位:sex"].nil? ? "":m["選擇欄位:sex"],
        m["選擇欄位:year"].nil? ? "":m["選擇欄位:year"],
      ]
    end

    # ary << [
    #   "總計",
    #   sum["勾選欄位:convstore_get"].nil? ? "" : sum["勾選欄位:convstore_get"],
    #   sum["編輯欄位:address"].nil? ? "" : sum["編輯欄位:address"],
    #   sum["編輯欄位:area"].nil? ? "" : sum["編輯欄位:area"],
    #   sum["編輯欄位:check_password"].nil? ? "" : sum["編輯欄位:check_password"],
    #   sum["編輯欄位:email"].nil? ? "" : sum["編輯欄位:email"],
    #   sum["編輯欄位:mobile"].nil? ? "" : sum["編輯欄位:mobile"],
    #   sum["編輯欄位:name"].nil? ? "" : sum["編輯欄位:name"],
    #   sum["編輯欄位:password"].nil? ? "" : sum["編輯欄位:password"],
    #   sum["編輯欄位:phone"].nil? ? "" : sum["編輯欄位:phone"],
    #   sum["編輯欄位:q"].nil? ? "" : sum["編輯欄位:q"],
    #   sum["編輯欄位:recommend_code"].nil? ? "" : sum["編輯欄位:recommend_code"],
    #   sum["選擇欄位:county"].nil? ? "" : sum["選擇欄位:county"],
    #   sum["選擇欄位:day"].nil? ? "" : sum["選擇欄位:day"],
    #   sum["選擇欄位:district"].nil? ? "" : sum["選擇欄位:district"],
    #   sum["選擇欄位:month"].nil? ? "" : sum["選擇欄位:month"],
    #   sum["選擇欄位:sex"].nil? ? "" : sum["選擇欄位:sex"],
    #   sum["選擇欄位:year"].nil? ? "" : sum["選擇欄位:year"],
    # ]

    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    i = 0
    ary.each do |row|
      sheet1.row(i).replace(row)
      i += 1
    end

    @time_now = Time.now.to_f
    filename = Rails.root+"public/csv/圖靈#{date_str}-MYDAY未註冊會員報表.xls"
    book.write(filename)
    return "圖靈#{date_str}-MYDAY未註冊會員報表"
  end

  def write_xls filename, data #{sheet_name_1: [rows...], sheet_name_2: [rows...], ...}
    book = Spreadsheet::Workbook.new
    # byebug if Rails.env == "development"
    data.each do |k, ary|
      sheet = book.create_worksheet(name: k)
      i = 0
      ary.each do |row|
        sheet.row(i).replace(row)
        i += 1
      end
    end
    book.write(Rails.root+"public/xls/#{filename}")
  end

  private
  def prior_sunday(date)
    days_before = (date.wday + 6) % 7 + 1
    date.to_date - days_before
  end

  def prior_saturday(date)
    days_before = (date.wday + 0) % 7 + 1
    date.to_date - days_before
  end
end

=begin
  無GA帳號錯誤訊息
{
 "error": {
  "errors": [
   {
    "domain": "global",
    "reason": "insufficientPermissions",
    "message": "User does not have any Google Analytics account."
   }
  ],
  "code": 403,
  "message": "User does not have any Google Analytics account."
 }
}
=end

# gem install bundler passenger --no-ri --no-rdoc
# /opt/nginx/sbin/nginx -g 'daemon off;'
#
# REDIS_NAME=/stupefied_morse/redis
#
# BUNDLE_SILENCE_ROOT_WARNING=1
# BUNDLE_APP_CONFIG=/usr/local/bundle
# REDIS_PORT_6379_TCP_ADDR 172.17.0.2
# passenger_env_var REDIS_PORT_6379_TCP_PORT 6379
# REDIS_ENV_GOSU_VERSION=1.7
#
# export GOOGLE_CLIENT_ID=782362301580-bnlu7s7gmjv9htlh65837ufjes6ptd37.apps.googleusercontent.com;
# export GOOGLE_CLIENT_SECRET=2dZLlxRKmeSqT5QmAl6tOPXC;
# export GOOGLE_API_KEY=AIzaSyD2WRzzla118fiEyom6nWML5Ob19FGtTfo;
