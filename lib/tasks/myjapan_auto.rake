# /lib/tasks/dev.rake

namespace :myjapan_auto do

  desc "myjapan_auto"

  task :run => :environment do
    u = User.where(email: 'analytics@turingdigital.com.tw').first
    ana = Analytics.new u
    mj = ana.myjapanHK_auto('96435422')
    ary = mj["rows"]
    ary.find_all {|ay| ay[0]=="確認點擊"}.map {|ay| ay[2]}.each{|_id| ary.delete_if {|ay| ay[2]==_id}}
    # ary.each {|ay| puts "#{ay[2]},會員註冊,#{ay[0]},#{ay[1]},#{ay[3]}"}

    ic = Iconv.new("big5", "utf-8")
    CSV.open(Rails.root+"public/csv/myjapan_#{(Date.today-1).to_s}.csv", "wb", encoding: 'BIG5') do |csv|
      csv << ["Client ID", "事件類別", "事件動作", "活動標籤", "事件總數"].map {|str| ic.iconv(str)}
      ary.each {|ay|
        puts "#{ay[2]},會員註冊,#{ay[0]},#{ay[1]},#{ay[3]}"
        csv << [ay[2],ic.iconv("會員註冊"),ic.iconv(ay[0]),ic.iconv(ay[1]),ay[3]]
      }
      
    end
  end

end
