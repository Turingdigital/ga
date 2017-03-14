# /lib/tasks/dev.rake
# require 'rufus-scheduler'

# require 'nokogiri'
# require 'open-uri'
# require 'retriever'

namespace :foo do

  desc "Testing"
  # task :rebuild => ["db:drop", "db:setup", :fake]
# <a id="LinkButton1" href="javascript:__doPostBack('LinkButton1','')">確定送出</a>

# theForm.__EVENTTARGET.value = 'LinkButton1';
# theForm.__EVENTARGUMENT.value = '';
#
# function check1(){
#   if(theForm.ODName.value != "" &&
#     theForm.r1.value != "" &&
#     theForm.ODTelZip.value != "" &&
#     theForm.ODTel.value != "" &&
#     theForm.ODCell.value.match(/0/) &&
#     theForm.ODMail.value.match(/.*@.*\.*/) &&
#     theForm.ODWay.value != "0" &&
#     theForm.ODCounty.value != "0")
#     return true;
#   return false;
# }

# (function(){
#   if(((theForm.ODName.value != "" &&
#     theForm.r1.value != "" &&
#     theForm.ODTelZip.value != "" &&
#     theForm.ODTel.value != "" &&
#     theForm.ODCell.value.match(/0/) &&
#     theForm.ODMail.value.match(/.*@.*\.*/) &&
#     theForm.ODWay.value != "0" &&
#     theForm.ODCounty.value != "0"))
#     &&
# 	((theForm.opMOEPARENT_Q.value != "" &&
#     theForm.opMOENAME_Q.value != "" &&
#     theForm.txtAMOUNT.value != "") ||
#
#     (theForm.opMOEPARENT_Q2.value != "" &&
#     theForm.opMOENAME_Q2.value != "" &&
#     theForm.txtAMOUNT2.value != "") ||
#
#     (theForm.opMOEPARENT_Q3.value != "" &&
#     theForm.opMOENAME_Q3.value != "" &&
#     theForm.txtAMOUNT3.value != "") ||
#
#     (theForm.opMOEPARENT_Q4.value != "" &&
#     theForm.opMOENAME_Q4.value != "" &&
#     theForm.txtAMOUNT4.value != "") ||
#
#     (theForm.opMOEPARENT_Q5.value != "" &&
#     theForm.opMOENAME_Q5.value != "" &&
#     theForm.txtAMOUNT5.value != "")))
#     return true;
# })();

  # task :thr => :environment do
  #   def fab n
  #     return n if n < 2
  #     return fab(n-1)+fab(n-2)
  #   end
  #
  #   puts fab(300)
  #   # 4.times{Thread.new {puts fab(300)}.join}
  # end

  task :crawler => :environment do
    opts = {
      'maxpages' => 10000
    }

    gtm_req = /}\)\(window,document,'script','dataLayer','GTM-.*'\);/
    ga_req = /ga\('create', '.*', 'auto'\);/

    File.open('/tmp/yourfile', 'w') do |file|
      # http://td.turingdigital.com.tw
      # http://www.adup.com.tw
      string = ""
      t = Retriever::PageIterator.new('https://www.easyrent.com.tw/', opts) do |page|
        # doc = Nokogiri::HTML(page.source)
        # puts page.url
        string += "#{page.url}\n"
        # doc.xpath("//script").grep(gtm_req).each do |ctx|
        #   scp = ctx.to_s
        #   puts "\t#{scp[scp.index('GTM-')..-13]}"
        # end
      end
      file.write(string)
    end

    # doc = Nokogiri::HTML(open("http://www.adup.com.tw/"))
    # # doc = Nokogiri::HTML(open("http://www.leosys.com/"))
    #
    # # GTM
    # doc.xpath("//script").grep(gtm_req).each do |ctx|
    #   scp = ctx.to_s
    #   puts scp[scp.index('GTM-')..-13]
    # end
    #
    # #GA
    # doc.xpath("//script").grep(ga_req).each do |ctx|
    #   scp = ctx.to_s
    #   idx = scp.index('UA-')
    #   puts scp[idx..(idx+12)]
    # end
  end

  task :foo => :environment do
    # scheduler = Rufus::Scheduler.singleton
    # # scheduler = Rufus::Scheduler.new
    # scheduler.in '3s' do
    #   puts "ok 1"
    #   Foo.create(title: "Test Data", start_date: DateTime.now)
    #   puts "ok 2"
    # end
    User.all.each{|u| puts Analytics.new(u).authorize ? "OK:#{u.email}" : "Fail:#{u.email}"}
  end

  task :morgal => :environment do
    u = User.find(2)
    profile_id = "51021694"#u.account_summary.default_profile
    ana = Analytics.new u

    ary = []
    dates = [["2016-07-10", "2016-07-16"], ["2016-07-17", "2016-07-23"], ["2016-07-31", "2016-08-06"], ["2016-08-07", "2016-08-13"]]
    dates.each { |d| ary << [ d, (ana.get_morgal( profile_id, d[0], d[1], 1, 20 )["rows"] ) ] }
    CSV.open("tmp/morgal2.csv", "wb") do |csv|
      ary.each do |data|
        csv << ["", data.first[0], data.first[1]]
        csv << ["", "搜尋字詞", "被查次數",	"搜尋離開率", "重複搜尋率"]
        cnt = 1
        data.last.each do |da|
          puts da[4]
          csv << [cnt, da[0], da[1], "#{da[3].to_f.round(2)}%", "#{da[2].to_f.round(2)}%"]
          cnt += 1
        end
        csv << []
      end
    end
  end
end
