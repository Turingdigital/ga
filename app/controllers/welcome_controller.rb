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
    ary.find_all {|ay| ay[0]=="確認點擊"}.map {|ay| ay[2]}.each{|_id| ary.delete_if {|ay| ay[2]==_id}}
    # ary.each {|ay| puts "#{ay[2]},會員註冊,#{ay[0]},#{ay[1]},#{ay[3]}"}

    ic = Iconv.new("big5", "utf-8")
    filename = "myjapan_#{(Date.today-1).to_s}"
    CSV.open(Rails.root+"public/csv/#{filename}.csv", "wb", encoding: 'BIG5') do |csv|
      csv << ["Client ID", "事件類別", "事件動作", "活動標籤", "事件總數"].map {|str| ic.iconv(str)}
      ary.each {|ay|
        puts "#{ay[2]},會員註冊,#{ay[0]},#{ay[1]},#{ay[3]}"
        csv << [ay[2],ic.iconv("會員註冊"),ic.iconv(ay[0]),ic.iconv(ay[1]),ay[3]]
      }
    end

    UserMailer.notify_comment(filename).deliver_now!
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
