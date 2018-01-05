class WelcomeController < ApplicationController
  layout false

  def index
    redirect_to user_user_path(current_user) if user_signed_in?
       #.account_summary if current_user.account_summary
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
    filename = (save_result report, start_date, end_date)
    date_str = "#{start_date_date.strftime('%m/%d')}~#{end_date_date.strftime('%m/%d')}"
    UserMailer.myday_b01(filename, date_str).deliver_now!
  end

  private
  # def save_result data, sum, start_date, end_date
  def save_result data, start_date, end_date
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
    filename = Rails.root+"public/csv/myday_b01_#{start_date}_#{end_date}.xls"
    book.write(filename)
    return "myday_b01_#{start_date}_#{end_date}"
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
