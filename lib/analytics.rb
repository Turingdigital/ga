# Copyright 2016 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'google/apis/analytics_v3'
# require 'google/apis/servicemanagement_v1'
require 'googleauth'

# require Rails.env.development? ? 'googleauth/stores/file_token_store' : 'googleauth/stores/redis_token_store'
require 'googleauth/stores/file_token_store'
GA_DATA_REDIS_EXPIRE_TIME = 60*60*8

module Authorizer
  CALLBACK_URI = 'http://localhost:3000/oauth/ga_callback'
  CLIENT_ID = Google::Auth::ClientId.new('782362301580-bnlu7s7gmjv9htlh65837ufjes6ptd37.apps.googleusercontent.com', '2dZLlxRKmeSqT5QmAl6tOPXC')
  SCOPE = Google::Apis::AnalyticsV3::AUTH_ANALYTICS
  # ref https://github.com/redis/redis-rb
  # redis = Redis.new(:host => "10.0.1.1", :port => 6380, :db => 0, :path => "/tmp/redis.sock", :password => "mysecret")

  TOKEN_STORE = Google::Auth::Stores::FileTokenStore.new(:file => Rails.root+"google_auth_stores")

  AUTHORIZER = Google::Auth::UserAuthorizer.new(CLIENT_ID, SCOPE, TOKEN_STORE, CALLBACK_URI)

  def self.credentials user_id
    return AUTHORIZER.get_credentials(user_id)
  end

  def self.store_credentials(user_id, credentials)
    AUTHORIZER.store_credentials(user_id, credentials)
  end
end

class Analytics #< BaseCli

  # @@OOB_URI = 'http://localhost:3000/oauth/ga_callback'
  # @@CALLBACK_URI = 'http://localhost:3000/oauth/ga_callback'
  # @@client_id = Google::Auth::ClientId.new('782362301580-bnlu7s7gmjv9htlh65837ufjes6ptd37.apps.googleusercontent.com', '2dZLlxRKmeSqT5QmAl6tOPXC')

  def initialize user
    @user = user
    @analytics = Google::Apis::AnalyticsV3::AnalyticsService.new
    @redis = Redis.new(
      host: 'localhost',
      port: 6379,
      db: 2)
  end

  # 批量檢查認證
  # User.all.each{|u| puts Analytics.new(u).authorize ? "OK:#{u.email}" : "Fail:#{u.email}"}
  def authorize
    @analytics.authorization = Authorizer.credentials(@user.email)
    return @analytics.authorization ? true : false
  end

  def reload_authorizer_store_credentials_from_model
    # authorizer.store_credentials('isaac@adup.com.tw', cred)
    Authorizer.store_credentials(@user.email, @user.ga_credential)
  end

  def snailhouse
    # sessions::condition::ga:sourceMedium==yahoo / organic;
    # sessions::condition::ga:userType==Returning Visitor;
    # sessions::condition::ga:userGender==female;
    # sessions::condition::ga:userAgeBracket==35-44
    #
    # sessions::condition::ga:userGender==female;sessions::condition::ga:userAgeBracket==35-44

# sessions::condition::ga:eventAction==checkout
# checkout	1	1,782
# checkout	2	603
# checkout	3	237
# 292
#
# checkout	1	306
# checkout	2	204
# checkout	3	123
# 124
#
# var tfloor = -1;
# var dfloor='';
# if(tfloor == 1){
# 	dfloor ='1';
# }else if(tfloor >= 2 &&  tfloor <= 5){
# 	dfloor ='2-5';
# }else if(tfloor >= 6 &&  tfloor <= 9){
# 	dfloor ='6-9';
# }else if(tfloor >= 10){
# 	dfloor ='10+';
# }else{
#   dfloor ='其他';
# }
#
# dataLayer.push({
# 	event: '樓層',
# 	'樓層': dfloor
# });
#
# if( pRatio >= 1 && pRatio< 21 ){
#  	dpRatio ='1-20%';
# }else if( pRatio >= 21 && pRatio< 26 ){ //若剛好>20但<21的數字會漏掉
#  	dpRatio ='21-25%';
# }else if( pRatio >= 26 && pRatio< 31 ){
#  	dpRatio ='26-30%';
# }else if( pRatio >= 31 && pRatio< 36 ){
#  	dpRatio ='31-35%';
# }else if( pRatio >=31  ){
#  	dpRatio ='35% +';
# }else{
#   dpRatio ='無公設';
# }
#
# var unitPriceRang='';
# if(unit_price  < 20 ){
# 	unitPriceRang='0-19.9';
# }else if(unit_price >= 20 &&  unit_price  < 30 ){
# 	unitPriceRang='20.0-29.9';
# }else if(unit_price >= 30 &&  unit_price  < 40 ){
# 	unitPriceRang='30.0-39.9';
# }else if(unit_price >= 40 &&  unit_price  < 50 ){
# 	unitPriceRang='40.0-49.9';
# }else if(unit_price >= 50 &&  unit_price  < 60 ){
# 	unitPriceRang='50.0-59.9';
# }else if(unit_price >= 60 &&  unit_price  < 70 ){
# 	unitPriceRang='60.0-69.9';
# }else if(unit_price >= 70 &&  unit_price  < 80 ){
# 	unitPriceRang='70.0-79.9';
# }else if(unit_price >= 80 &&  unit_price  < 90 ){
# 	unitPriceRang='80.0-89.9';
# }else if(unit_price >= 90 &&  unit_price  < 100 ){
# 	unitPriceRang='90.0-99.9';
# }else if(unit_price >= 100  ){
# 	unitPriceRang='100.0+';
# }else{
#   unitPriceRang='其他';
# }
#
# dataLayer.push({
# 	event: '單價/坪',
# 	'單價/坪': unitPriceRang
# });



# sessions::condition::ga:eventAction==checkout;sessions::condition::ga:eventLabel==3
#     # /object/18177?s=I20
#     # /object/18524?s=I26
#     /object/18563
#     /object/18744?s=I30
#     # /object/18760
#     # /object/18820?s=I26
#     /object/18851
#     # /object/18886?s=I20
#     # /object/18953
#
#     /object/18563
#     /object/18744?s=I30
#     /object/18851
#     /object/18953
#
#     /object/18524?s=I26
#     /object/18886?s=I20

  end

  def segment profile_id
    authorize

    # purchase = @analytics.get_ga_data( "ga:#{profile_id}", "2017-04-01", "2017-04-30", ['ga:totalEvents'],{
    #   dimensions: 'ga:eventLabel',
    #   filters: 'ga:eventAction==purchase',
    # })
    # p = purchase.rows.inject([]) {|ary, obj| ary << obj.first}

    # p.each do ||
    #   result = @analytics.get_ga_data( "ga:#{profile_id}", "2017-04-01", "2017-04-30", ['ga:totalEvents'],{
    #     dimensions: 'ga:eventLabel',
    #     filters: 'ga:eventAction==purchase',
    #     segment: 'sessions::condition::ga:eventLabel==00Q01704EV63'
    #   })
    # end

    ecomm = @analytics.get_ga_data( "ga:#{profile_id}", "2017-04-01", "2017-04-30", ['ga:itemRevenue'],{
      dimensions: 'ga:transactionId,ga:productName'
    })

    e = {}
    ecomm.rows.each {|obj|
      e[obj.first] = obj[1..-1]
    }

    threads = []

    result = {}
    e.each do |k, v|
      threads << Thread.new {
        promo = @analytics.get_ga_data( "ga:#{profile_id}", "2017-04-01", "2017-04-30", ['ga:totalEvents'],{
          dimensions: 'ga:eventLabel',
          filters: 'ga:eventAction==PromoClick',
          segment: "sessions::condition::ga:eventLabel==#{k}"
        })

        unless promo.rows.nil?
          result[promo.rows.first.first] = [0] if result[promo.rows.first.first].nil?
          result[promo.rows.first.first][0] += 1
          result[promo.rows.first.first] << [k, v]
        end
      }
      sleep 1
    end

    threads.each { |thr| thr.join }

    CSV.open("/Users/isaac/eye.csv", "wb") do |csv|
      csv << [result.to_json]
      # result.each do |k, v|
      #   total = v[1][1][-1].to_f
      #   row = [k, v[0], v[1][0], v[1][1][0]]
      #   v[1][2..-1].each do |p|
      #     row << ["","",p[0],p[1][0]]
      #     total = p[1][-1].to_f
      #   end
      #   csv << row
      # end
    end

    # cnt = 0
    # ecomm.rows.each {|obj| e[obj.first] = obj.second }

#     require 'csv'
#
# map = {"(not set)"=>[28,["00051704EA11",["美麗秘密矽水膠月拋隱形眼鏡(1片裝)","672.0"]],["00051704ET75",["美麗秘密彩色季拋隱形眼鏡-大自然棕(1片裝)","398.0"]],["00141704EY62",["珂朗清矽水膠日拋軟性隱形眼鏡(30片裝)","580.0"]],["00371704EM85",["女主角彩色日拋隱形眼鏡-純粹 Pure Nude(10片裝)","1276.0"]],["00381704EK92",["睛艷日拋式彩色隱形眼鏡-Green(綠)(10片裝)","460.0"]],["00461704EB31",["舒視氧高透氧隱形眼鏡濕潤型(3片裝)","958.0"]],["00511704EE58",["睛靚玩美彩色隱形眼鏡-花漾黑(1片裝)","150.0"]],["00531704EO21",["美麗秘密彩色季拋隱形眼鏡-大自然棕(1片裝)","199.0"]],["00581704ED36",["美麗秘密彩色軟性隱形眼鏡-大銀石灰(1片裝)","289.0"]],["00611704EH23",["星眸彩色月拋隱形眼鏡-孔雀粉紅(1片裝)","100.0"]],["008C1704EC60",["RAYBAN 劃時代永恆巨星款 裘德洛同款 亞版星河黑 (2140F-901-52)","3680.0"]],["00991704EA79",["酷柏佰美視雙週拋軟式隱形眼鏡(6片裝)","538.0"]],["00B41704EV86",["女主角彩色日拋隱形眼鏡-純粹 Pure Nude(10片裝)","399.0"]],["00B41704ES72",["女主角彩色日拋隱形眼鏡-純粹 Pure Nude(10片裝)","399.0"]],["00B61704EP19",["美麗秘密矽水膠日拋隱形眼鏡(15片裝)","1680.0"]],["00F71704EG42",["睛靚玩美彩色隱形眼鏡-蕾絲黑(6片裝)","200.0"]],["03361704EK32",["女主角彩色日拋隱形眼鏡-純粹 Pure Nude(10片裝)","638.0"]],["05081704ER74",["睛靚玩美彩色隱形眼鏡-銀石灰(1片裝)","0.0"]],["05291704ET48",["海昌非球面日拋隱形眼鏡(30片裝)","555.0"]],["05321704EE54",["海昌非球面月拋隱形眼鏡(2片裝)","444.0"]],["05731704EP87",["RAYBAN 傳奇不朽經典飛官大框 布萊德彼特同款 永晝銀/漸變棕(3025-004/51-62)","3680.0"]],["05731704EZ30",["RAYBAN 傳奇不朽經典飛官 湯姆克魯斯同款 旭日金 (3025-L0205)","3680.0"]],["06621704EG54",["海昌非球面日拋隱形眼鏡(30片裝)","554.0"]],["06621704ER72",["海昌非球面日拋隱形眼鏡(30片裝)","1108.0"]],["06621704EV38",["海昌非球面日拋隱形眼鏡(30片裝)","555.0"]],["06701704EC65",["美麗秘密彩色季拋隱形眼鏡-大自然棕(1片裝)","199.0"]],["06701704ED66",["海昌非球面月拋隱形眼鏡(2片裝)","149.0"]],["06771704EZ49",["睛艷日拋彩色隱形眼鏡-星鑽棕(10片裝)","1017.0"]]],"上方廣告-雷朋嚴選優惠 熱銷冠軍 群組商品一律3680"=>[1,["00051704EN60",["RAYBAN 傳奇不朽經典飛官 太陽的後裔宋仲基同款大框 騎士黑 (3026-L2821)","3680.0"]]],"RICHBABY月拋 綺娜系列第2盒6折"=>[4,["00051704EO66",["綺娜彩色月拋隱形眼鏡-流星銀 Meteor(1片裝)","320.0"]],["00661704EC78",["綺娜彩色月拋隱形眼鏡-流星銀 Meteor(1片裝)","640.0"]],["00Q01704ET75",["星眸彩色月拋隱形眼鏡-羅馬綠(1片裝)","258.0"]],["05151704EX88",["睛艷日拋式彩色隱形眼鏡-Pure Hazel(棕)(10片裝)","339.0"]]],"太陽眼鏡-雷朋嚴選優惠 熱銷冠軍 群組商品一律3680"=>[1,["00051704EP19",["RAYBAN 傳奇不朽經典飛官 太陽的後裔宋仲基同款 騎士黑 (3025-L2823)","3680.0"]]],"RICHBABY日拋 女主角系列第2盒6折!再送KISS ME睫毛膏"=>[5,["00051704EQ19",["酷柏佰視明軟性隱形眼鏡(1片裝)","129.0"]],["00B61704ET45",["綺娜彩色月拋隱形眼鏡-流星銀 Meteor(1片裝)","400.0"]],["00B61704EV31",["綺娜彩色月拋隱形眼鏡-流星銀 Meteor(1片裝)","320.0"]],["00D41704EX55",["星眸彩色月拋隱形眼鏡-雪梨棕(1片裝)","1290.0"]],["05291704EJ13",["美麗秘密矽水膠月拋隱形眼鏡(1片裝)","225.0"]]],"上方廣告-倒數會員5倍送"=>[1,["00051704ER10",["睛靚玩美彩色隱形眼鏡-蕾絲黑(6片裝)","400.0"]]],"上方廣告-海昌第二盒半價"=>[2,["00111704EL89",["美麗秘密矽水膠日拋隱形眼鏡(5片裝)","0.0"]],["00111704EV89",["美麗秘密矽水膠日拋隱形眼鏡(5片裝)","0.0"]]],"【海昌購瘋狂】非球面月拋(2片裝)同品項 第2盒半價"=>[4,["00111704EO49",["海昌非球面月拋隱形眼鏡(2片裝)","198.0"]],["03141704ED44",["美麗秘密彩色季拋隱形眼鏡-大自然棕(1片裝)","199.0"]],["03141704ES53",["美麗秘密彩色季拋隱形眼鏡-大自然棕(1片裝)","199.0"]],["05291704EC62",["海昌非球面月拋隱形眼鏡(2片裝)","149.0"]]],"上方廣告-睛靚"=>[1,["00111704EX69",["睛靚玩美彩色隱形眼鏡-魅惑棕(6片裝)","100.0"]]],"博士倫舒服能散光日拋 2盒特價1,680元!再送7-11禮卷100元"=>[1,["00371704EL27",["博士倫舒服能日拋散光隱形眼鏡(30片裝)","3360.0"]]],"上方廣告-BOLON太陽眼鏡特價1980"=>[2,["00371704EO24",["美麗秘密矽水膠月拋隱形眼鏡(1片裝)","225.0"]],["02951704EG66",["美麗秘密矽水膠月拋隱形眼鏡(1片裝)","448.0"]]],"RAY.BAN 群組商品一律3680元 (雷朋嚴選限時搶購)"=>[3,["00381704ED45",["RAYBAN 傳奇不朽經典飛官大框 布萊德彼特同款 日耀金/漸變棕(3025-001/51-62)","3680.0"]],["00811704EN51",["RAYBAN 傳奇不朽經典飛官 太陽的後裔宋仲基同款 騎士黑 (3025-L2823)","3680.0"]],["06771704EV43",["星眸彩色日拋隱形眼鏡-星鑽黑(10片裝)","716.0"]]],"博士倫睛緻美彩色日拋(30片裝)2盒特價1,275元"=>[1,["00461704EF69",["博士倫睛緻美彩色每日拋棄式隱形眼鏡-魅力棕(30片裝)","1275.0"]]],"愛爾康舒視氧月拋全系列 (3片裝) 任選2盒折200元!"=>[1,["00461704EJ71",["舒視氧高透氧隱形眼鏡濕潤型(3片裝)","800.0"]]],"光學框/濾藍光平光-類別小看板-K-DESIGN光學框"=>[1,["00461704EQ52",["加美醉心彩色拋棄式軟性隱形眼鏡-深棕(Brown)(1片裝)","200.0"]]],"美麗秘密彩色季拋\u0026半年拋指定商品同品項買1送1!"=>[2,["00511704EG97",["美麗秘密彩色季拋隱形眼鏡-大時尚灰(1片裝)","199.0"]],["00B61704EH49",["美麗秘密彩色軟性隱形眼鏡-大銀石灰(1片裝)","578.0"]]],"【海昌購瘋狂】非球面日拋(30片裝)同品項 第2盒半價"=>[3,["00511704EQ63",["海昌非球面日拋隱形眼鏡(30片裝)","1108.0"]],["00941704EQ90",["海昌非球面日拋隱形眼鏡(30片裝)","1108.0"]],["02951704EK24",["海昌非球面日拋隱形眼鏡(30片裝)","555.0"]]],"RICHBABY日拋 優梨雅系列第2盒6折!再送KISS ME睫毛膏"=>[11,["00541704EC38",["綺娜彩色月拋隱形眼鏡-天王星棕 Uranus(1片裝)","320.0"]],["00611704EE39",["綺娜彩色月拋隱形眼鏡-流星銀 Meteor(1片裝)","320.0"]],["00611704EH57",["綺娜彩色月拋隱形眼鏡-流星銀 Meteor(1片裝)","320.0"]],["00811704EB14",["綺娜彩色月拋隱形眼鏡-彗星可可 Comet(1片裝)","320.0"]],["00A81704EY81",["睛靚玩美彩色隱形眼鏡-彩蝶金(6片裝)","200.0"]],["00B61704ES65",["星眸彩色月拋隱形眼鏡-孔雀紫(1片裝)","100.0"]],["02951704EX15",["綺娜彩色月拋隱形眼鏡-彗星可可 Comet(1片裝)","320.0"]],["03251704EF61",["女主角彩色日拋隱形眼鏡-綻放 Aria Brown(10片裝)","319.0"]],["03361704EQ65",["睛靚玩美彩色隱形眼鏡-蕾絲棕(6片裝)","100.0"]],["03991704EQ31",["星眸彩色日拋隱形眼鏡-心機灰(10片裝)","1470.0"]],["03991704EQ44",["優梨雅彩色日拋隱形眼鏡-項鍊 Melty Brown(10片裝)","560.0"]]],"愛爾康睛艷彩日拋系列任選2盒折100元"=>[4,["00581704ED28",["精華帝康彩色拋棄式軟性隱形眼鏡-黑色(1片裝)","340.0"]],["00611704EA88",["加美醉心彩色拋棄式軟性隱形眼鏡-灰色(Gary)(1片裝)","200.0"]],["02841704EB10",["睛艷日拋式彩色隱形眼鏡-Blue(藍)(10片裝)","460.0"]],["06621704EO47",["睛艷日拋式彩色隱形眼鏡-Pure Hazel(棕)(10片裝)","230.0"]]],"珂朗清日拋好禮成雙!"=>[2,["00661704EL61",["珂朗清矽水膠日拋軟性隱形眼鏡(30片裝)","1160.0"]],["02941704EY24",["珂朗清矽水膠日拋軟性隱形眼鏡(30片裝)","1160.0"]]],"海昌星眸彩月孔雀系列任選1副+100元再多1副!"=>[1,["00811704EO40",["星眸彩色月拋隱形眼鏡-孔雀金(1片裝)","198.0"]]],"上方廣告-孔雀"=>[3,["00811704EO86",["美麗秘密彩色軟性隱形眼鏡-大琥珀棕(1片裝)","289.0"]],["00Q01704EW17",["睛靚玩美彩色隱形眼鏡-魅惑灰(6片裝)","100.0"]],["06701704EB60",["睛靚玩美彩色隱形眼鏡-彩蝶灰(6片裝)","200.0"]]],"【會員獨家】睛靚彩月拋or雙週拋 買2副送2副!"=>[4,["00831704EA91",["美麗秘密抗UV非球面雙週拋隱形眼鏡(6片裝)","748.0"]],["008C1704ES44",["美麗秘密彩色軟性隱形眼鏡-大琥珀棕(1片裝)","289.0"]],["00991704EL66",["睛艷日拋式彩色隱形眼鏡-Green(綠)(10片裝)","230.0"]],["00D41704ED94",["美麗秘密彩色季拋隱形眼鏡-大自然棕(1片裝)","398.0"]]],"【新品優惠】珂朗清漸進多焦日拋 2盒特價2,000元"=>[2,["00941704EA99",["酷柏佰視明散光拋棄式軟性隱形眼鏡(3片裝)","1518.0"]],["00941704EV21",["酷柏佰視明散光拋棄式軟性隱形眼鏡(3片裝)","1518.0"]]],"【會員獨家】Total1 愛爾康全涵氧買2盒送2盒再省200元，單筆買滿4盒再送7-11商品卡50元"=>[3,["00941704EC53",["安視優歐舒適每日拋棄式隱形眼鏡(30片裝)","1890.0"]],["00941704EG84",["安視優歐舒適每日拋棄式隱形眼鏡(30片裝)","1890.0"]],["00941704EK99",["睛靚玩美彩色隱形眼鏡-花漾棕(1片裝)","150.0"]]],"愛爾康多水潤日拋(散光/多焦系列) 同品項2盒折200元"=>[1,["00941704EJ46",["安視優歐舒適每日拋棄式隱形眼鏡(30片裝)","1890.0"]]],"BOLON太陽眼鏡特價1980"=>[1,["00941704EN54",["睛艷日拋式彩色隱形眼鏡-Pure Hazel(棕)(10片裝)","460.0"]]],"隱形眼鏡彩片-rb"=>[1,["00B41704EA90",["女主角彩色日拋隱形眼鏡-純粹 Pure Nude(10片裝)","638.0"]]],"隱形眼鏡彩片-年拋"=>[1,["00B41704EZ92",["睛靚玩美彩色隱形眼鏡-花漾黑(1片裝)","150.0"]]],"【限時超值大包裝】愛爾康多水潤4盒特價1,450元"=>[1,["00B61704ED25",["安視優超涵水每日拋棄式隱形眼鏡(30片裝)","525.0"]]],"嬌生歐舒適雙週拋系列 同品項買4盒折400元!"=>[3,["00D41704ED24",["酷柏佰視明軟性隱形眼鏡(6片裝)","679.0"]],["06621704EA86",["安視優超涵水每日拋棄式隱形眼鏡(90片裝)","1495.0"]],["06621704EL36",["安視優超涵水每日拋棄式隱形眼鏡(90片裝)","1495.0"]]],"【海昌購瘋狂】非球面日拋(10片裝)同品項 第2盒半價"=>[2,["00E11704EF24",["珂朗清矽水膠日拋軟性隱形眼鏡(30片裝)","580.0"]],["03361704ED10",["海昌非球面日拋隱形眼鏡(10片裝)","225.0"]]],"上方廣告-愛爾康大包裝"=>[1,["00F71704EC72",["睛艷日拋式彩色隱形眼鏡-Pure Hazel(棕)(10片裝)","1017.0"]]],"【睛靚大方送】彩月拋or雙週拋 買2副送2副!"=>[1,["03361704EC10",["綺娜彩色月拋隱形眼鏡-流星銀 Meteor(1片裝)","400.0"]]],"美麗秘密彩色半年拋指定商品同品項買1送1!"=>[1,["05531704EA18",["美麗秘密彩色季拋隱形眼鏡-大自然棕(1片裝)","398.0"]]],"【4/1~5/15感恩母親回饋】舒服能漸進多焦雙週拋送精華液(市價3,200元)"=>[1,["06771704EC15",["博士倫純視二代散光軟式隱形眼鏡(1片裝)","630.0"]]]}
#
# CSV.open("/Users/isaac/eye.csv", "wb") do |csv|
#   map.each do |k, v|
#     total = v[1][1][-1].to_f
#     row = [k, v[0], v[1][0], v[1][1][0]]
#     # p v[2..-1]
#     # break
#     csv << row
#     p v[2..-1]
#     v[2..-1].each do |p|
#       row = ["","",p[0],p[1][0]]
#       total += p[1][-1].to_f
#       csv << row
#     end
#     csv << ["","",total]
#   end
# end

  end

  def filter
    filter = Google::Apis::AnalyticsV3::Filter.new
    filter.account_id = '82010902'
    filter.name = 'genByApi'
    filter.type = 'EXCLUDE'
    filter.exclude_details = {
      field: 'REFERRAL', # GEO_DOMAIN
      match_type: 'EQUAL',
      expression_value: 'example.com',
      case_sensitive: false
    }
    authorize
    # @analytics.insert_filter('82010902', filter)
    @analytics.insert_profile_filter_link('82010902', 'UA-82010902-2', '128311370')
  end

  # 有自己的Model儲存，所以不用Cache
  def accountSummaries
    # unless self.authorized?
    # result = get_cached profile_id, _start, _end
    # return result if result

    authorize

    begin
      result = @analytics.list_account_summaries
      # set_cached(result, profile_id, _start, _end)
      # return get_cached profile_id, _start, _end
      return result
    rescue Exception => e
      return false
    end
  end

  def show_visits(profile_id, _start, _end)
    dimensions = %w(ga:date)
    metrics = %w(ga:sessions ga:users ga:newUsers ga:percentNewSessions
                 ga:sessionDuration ga:avgSessionDuration)
    sort = %w(ga:date)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort)
  end

  def get_visits(profile_id, _start, _end)
    dimensions = %w(ga:date)
    metrics = %w(ga:sessions ga:users ga:newUsers ga:percentNewSessions
                 ga:sessionDuration ga:avgSessionDuration)
    sort = %w(ga:date)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort)
  end

  def get_visits_all_and_new(profile_id, _start, _end)
    dimensions = %w(ga:yearMonth)
    metrics = %w(ga:users ga:newUsers)
    sort = %w(ga:yearMonth)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort)
  end

  # ga:source==Line;ga:medium==POST;ga:adContent==line_圖文_午;ga:campaign=="170313-24_野餐用品";ga:keyword==line_每日po文_item_10
  # 都要變小寫
  def get_sessions_filter_canpaign_today(
        profile_id,
        source,
        medium,
        adContent,
        campaign,
        keyword,
        _start="today",
        _end="today")
    metrics = %w(ga:sessions)
    # dimensions = %w(ga:nthHour)
    filter = "ga:source==#{source};ga:medium==#{medium};ga:adContent==#{adContent};ga:campaign==#{campaign};ga:keyword==#{keyword}"
    # sort = %w(-ga:searchResultViews)
    return get_ga_data(profile_id, _start, _end, metrics, nil, nil, filter)
  end

  def get_searchs_div_searchKeyword(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w(ga:searchResultViews ga:percentSearchRefinements ga:searchExitRate)
    dimensions = %w(ga:searchKeyword)
    sort = %w(-ga:searchResultViews)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort)
  end

  def get_users_sessions_goalCompletionsAll_pageViews(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w(ga:sessions ga:users ga:pageviews ga:goalCompletionsAll)
    return get_ga_data(profile_id, _start, _end, metrics)
  end

  def get_users_sessions_goalCompletionsAll_pageViews_div_nthweek(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w(ga:sessions ga:users ga:pageviews ga:goalCompletionsAll)
    dimensions = %w(ga:nthWeek)
    sort = %w(ga:nthWeek)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort)
  end

  def get_sessions_goalCompletionsAll_div_source(profile_id, _start="30daysAgo", _end="yesterday")
    metrics = %w(ga:sessions ga:goalCompletionsAll)
    dimensions = %w(ga:source)
    sort = %w(ga:sessions)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort)
  end

  def get_sessions profile_id, _start="7daysAgo", _end="yesterday"
    metrics = %w(ga:sessions)
    return get_ga_data(profile_id, _start, _end, metrics)
  end

  def get_campaign_sessions profile_id, _start="7daysAgo", _end="yesterday"
    dimensions = %w(ga:source ga:medium ga:date)
    metrics = %w(ga:sessions)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions)
  end

  def get_sourceMedium_sessions profile_id, _start="7daysAgo", _end="yesterday"
    dimensions = %w(ga:sourceMedium)
    metrics = %w(ga:sessions)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions)
  end

  def get_event_sessions profile_id, _start="7daysAgo", _end="yesterday"
    dimensions = %w(ga:eventCategory ga:eventAction ga:eventLabel)
    metrics = %w(ga:sessions)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions)
  end

  def list_goals options={} #accountId, webPropertyId, profileId
    result = get_cached profile_id, _start, _end
    return result if result

    authorize

    accountId     = '~all' unless options[:accountId]
    webPropertyId = '~all' unless options[:webPropertyId]
    profileId     = '~all' unless options[:profileId]
    result = @analytics.list_goals(accountId, webPropertyId, profileId)
    set_cached(result, profile_id, _start, _end)
    return get_cached profile_id, _start, _end
  end

  def get_realtime_data(profile_id)
    result = get_cached profile_id, 'realtime', 'realtime'
    return result if result

    authorize

    dimensions = %w(ga:date)
    metrics = %w(rt:activeUsers)
    result = @analytics.get_realtime_data("ga:#{profile_id}", metrics.join(','))
    set_cached(result, profile_id, 'realtime', 'realtime')
    return get_cached profile_id, 'realtime', 'realtime'
  end

  # def oauth_url
  #   url = @authorizer.get_authorization_url(base_url: @@OOB_URI)
  # end


  ###########
  # HOT Car #
  ###########
  def page1(profile_id, _start="7daysAgo", _end="yesterday", filters=nil, segment=nil)
    metrics = %w( ga:users
                  ga:sessions
                  ga:pageviews
                  ga:bounceRate
                  ga:avgSessionDuration
                  ga:newUsers )
    dimensions = nil # %w(ga:deviceCategory)
    # sort = %w(-ga:searchResultViews)
    # filters = %w(ga:deviceCategory!=desktop)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, nil, filters, segment)
  end
  def page1_1(profile_id, _start="7daysAgo", _end="yesterday", filters=nil, segment=nil)
    metrics = %w( ga:users
                  ga:sessions )

    dimensions = nil # %w(ga:deviceCategory)
    # sort = %w(-ga:searchResultViews)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, nil, filters, segment)
  end

  def event_1(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w(ga:eventAction )
    # sort = %w(-ga:searchResultViews)
    filters = %w(ga:eventCategory==首頁:左側搜尋)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, nil, filters)
  end

  def event_2(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w(ga:eventAction )
    sort = %w(-ga:totalEvents)
    filters = %w(ga:eventCategory==首頁:快速搜尋)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_3(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w(ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==首頁:快速搜尋;ga:eventAction==搜尋廠牌"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_4(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w(ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==首頁:快速搜尋;ga:eventAction==搜尋車型"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_5(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventAction ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==首頁:快速搜尋;ga:eventAction=@搜尋年份"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_6(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==首頁:快速搜尋;ga:eventAction==搜尋城市"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_7(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==首頁:快速搜尋;ga:eventAction==搜尋區域"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_8(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventAction ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==知識專區"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_9(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventAction ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==最新消息"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_10(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w( ga:eventAction )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==全站:右側頁籤"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_11(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==首頁:白金/金質車商"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_12(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==首頁:熱門/成交車商"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_13(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w( ga:eventAction )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==首頁:熱門/成交車商"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_14(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==手機版"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_15(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==選擇器;ga:eventAction==手機版選擇器: 選取廠牌"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def event_16(profile_id, _start="7daysAgo", _end="yesterday", filters=nil)
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==選擇器;ga:eventAction==手機版選擇器: 選取車型"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  #########
  # IRent #
  #########
  def irent_1(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:sessions )

    dimensions = %w( ga:deviceCategory )
    sort = %w(-ga:sessions)
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort)
  end

  def irent_2(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==按鈕;ga:eventAction==電腦版點擊"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def irent_3(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==按鈕;ga:eventAction==手機版點擊"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def irent_4(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==選擇器;ga:eventAction==電腦版選擇地區"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def irent_5(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==選擇器;ga:eventAction==手機版選擇地區"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def irent_6(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==選擇器;ga:eventAction==電腦版選擇服務據點"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def irent_7(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==選擇器;ga:eventAction==手機版選擇服務據點"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def irent_8(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventAction )
    sort = nil #%w(-ga:totalEvents)
    filters = "ga:eventCategory==video"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def irent_9(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:userGender )
    sort = nil #%w(-ga:totalEvents)
    filters = "ga:eventCategory==video;ga:eventAction==Playing"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def irent_10(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:userAgeBracket )
    sort = nil #%w(-ga:totalEvents)
    filters = "ga:eventCategory==video;ga:eventAction==Playing"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def irent_11(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:operatingSystem )
    sort = nil #%w(-ga:totalEvents)
    filters = "ga:eventCategory==按鈕;ga:eventLabel=~下載APP_下|GooglePlay下載|App Store下載"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def irent_12(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:mobileDeviceInfo )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==按鈕;ga:eventLabel=~下載APP_下|GooglePlay下載|App Store下載"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def irent_13(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:sessions ga:pageviews ga:bounceRate )

    dimensions = %w( ga:sourceMedium )
    sort = %w(-ga:sessions)
    filters = nil # "ga:eventCategory==按鈕;ga:eventLabel=~下載APP_下|GooglePlay下載|App Store下載"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def irent_13_1(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:sourceMedium )
    sort = nil #%w(-ga:sessions)
    filters = "ga:eventCategory==按鈕;ga:eventLabel=~下載APP_下|GooglePlay下載|App Store下載"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def irent_14(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:sessions )

    dimensions = %w( ga:userType ga:userGender ga:userAgeBracket )
    sort = nil #%w(-ga:sessions)
    filters = nil #"ga:eventCategory==按鈕;ga:eventLabel=~下載APP_下|GooglePlay下載|App Store下載"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def irent_14_1(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:userType ga:userGender ga:userAgeBracket )
    sort = nil #%w(-ga:sessions)
    filters = "ga:eventCategory==按鈕;ga:eventLabel=~下載APP_下|GooglePlay下載|App Store下載"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters)
  end

  def irent_15(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==選擇器;ga:eventAction==選擇器: 取車地點"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, 'sessions::condition::ga:pagePath=~WEB110.ASPX|/WEB110.aspx')
  end

  def irent_16(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==選擇器;ga:eventAction==選擇器: 還車地點"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, 'sessions::condition::ga:pagePath=~WEB110.ASPX|/WEB110.aspx')
  end

  def irent_17(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==選擇器;ga:eventAction==選擇器: 取車站點"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, 'sessions::condition::ga:pagePath=~WEB110.ASPX|/WEB110.aspx')
  end

  def irent_18(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==選擇器;ga:eventAction==選擇器: 還車站點"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, 'sessions::condition::ga:pagePath=~WEB110.ASPX|/WEB110.aspx')
  end

  def irent_19(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==按鈕;ga:eventAction==點擊-優惠專案查詢"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, 'sessions::condition::ga:pagePath=~WEB110.ASPX|/WEB110.aspx')
  end

  def irent_20(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:totalEvents)
    filters = "ga:eventCategory==按鈕;ga:eventAction==點擊-訂購車型"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, 'sessions::condition::ga:pagePath=~WEB110.ASPX|/WEB110.aspx')
  end

  def irent_21(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:uniqueEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:uniqueEvents)
    filters = "ga:eventCategory==按鈕;ga:eventAction==點擊"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, 'sessions::condition::ga:pagePath=~WEB110.ASPX|/WEB110.aspx')
  end

  def irent_21_2(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:uniqueEvents )

    dimensions = %w( ga:eventAction )
    sort = %w(-ga:uniqueEvents)
    filters = "ga:eventCategory==按鈕;ga:eventAction==點擊下一步_我要租車後續頁"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, 'sessions::condition::ga:pagePath=~WEB110.ASPX|/WEB110.aspx')
  end

  def irent_22(profile_id, _start="7daysAgo", _end="yesterday")
    metrics = %w( ga:uniqueEvents )

    dimensions = %w( ga:eventLabel )
    sort = %w(-ga:uniqueEvents)
    filters = "ga:eventCategory==按鈕;ga:eventAction==點擊;ga:eventLabel=~點擊確認送出 - 進入付費頁面 -"
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, 'sessions::condition::ga:pagePath=~WEB110.ASPX|/WEB110.aspx')
  end

  def sstainan(profile_id, _start="7daysAgo", _end="yesterday", start_index=nil)
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel ga:pagePath )
    sort = nil # %w(-ga:uniqueEvents)
    filters = "ga:eventCategory==滾軸事件"
    segment = nil
    # start_index = 1001
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, segment, start_index)
  end

  def sstainan_pageview(profile_id, _start="7daysAgo", _end="yesterday", start_index=nil)
    metrics = %w( ga:pageviews ga:avgTimeOnPage )

    dimensions = %w( ga:pagePath ga:pageTitle )
    sort = %w( -ga:pageviews )
    filters = nil #{}"ga:eventCategory==滾軸事件"
    segment = nil
    # start_index = 1001
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, segment, start_index)
  end

  def sunamilife(profile_id, _start="7daysAgo", _end="yesterday", start_index=nil)
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventLabel ga:pagePath ga:pageTitle )
    sort = nil # %w(-ga:uniqueEvents)
    filters = "ga:eventCategory==滾軸事件"
    segment = nil
    # start_index = 1001
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, segment, start_index)
  end

  def myjapanHK_auto(profile_id, _start="yesterday", _end="yesterday", start_index=nil)
    metrics = %w( ga:totalEvents )

    dimensions = %w( ga:eventAction ga:eventLabel ga:dimension1 )
    sort = nil # %w( -ga:pageviews )
    filters = "ga:eventCategory==會員註冊" # nil #"ga:eventCategory==滾軸事件"
    segment = nil
    # start_index = 1001
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, segment, start_index)
  end

  def myday_b01(profile_id, _start="yesterday", _end="yesterday", start_index=nil)
    metrics = %w( ga:totalEvents ga:uniqueEvents )

    dimensions = %w( ga:eventAction ga:eventLabel ga:dimension2 )
    sort = nil # %w( -ga:pageviews )
    filters = "ga:eventCategory==會員註冊頁" # nil #"ga:eventCategory==滾軸事件"
    segment = "sessions::condition::ga:pagePath=@a_myday/login_start.php;ga:pagePath!@a_myday/member_form.php"
    # start_index = 1001
    return get_ga_data(profile_id, _start, _end, metrics, dimensions, sort, filters, segment, start_index)
  end

  private
    def get_cached profile_id, _start, _end, caller_method_name=nil, start_index
      caller_method_name ||= caller[0][/`.*'/][1..-2]
      result = @redis.get("#{@user.email}:#{profile_id}:#{_start}:#{_end}:#{caller_method_name}:#{start_index}")
      return result ? JSON.parse(result) : nil
    end

    def set_cached result, profile_id, _start, _end, caller_method_name=nil, start_index=1
      caller_method_name ||= caller[0][/`.*'/][1..-2]
      redis_key = "#{@user.email}:#{profile_id}:#{_start}:#{_end}:#{caller_method_name}:#{start_index}"
      @redis.set redis_key, result.to_json
      @redis.expire redis_key, GA_DATA_REDIS_EXPIRE_TIME
    end

    def get_ga_data profile_id, _start, _end, metrics, dimensions=nil, sort=nil, filters=nil, segment=nil, start_index=nil

      caller_method_name ||= (caller[0][/`.*'/][1..-2]+(filters.nil? ? "nofilter" : filters.to_s))

      result = get_cached(profile_id, _start, _end, caller_method_name, start_index)
      return result if result && !(caller_method_name =~ /page1|sstainan/)

      authorize

      arg = {}
      arg[:dimensions] = dimensions.join(',') if dimensions
      arg[:sort] = sort.join(',') if sort
      arg[:filters] = filters if filters # 假流量篩sessions
      arg[:segment] = segment if segment
      arg[:start_index] = start_index if start_index

      result = @analytics.get_ga_data(
                            "ga:#{profile_id}",
                            _start, _end,
                            metrics.join(','),
                            arg)

      set_cached(result, profile_id, _start, _end, caller_method_name, start_index)
      return get_cached(profile_id, _start, _end, caller_method_name, start_index)
    end
end

# ga:source==Line;ga:medium==POST;ga:adContent==line_圖文_午;ga:campaign==170313-24_野餐用品;ga:keyword==line_每日po文_item_10
