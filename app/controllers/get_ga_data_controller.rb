class GetGaDataController < ActionController::Base
  def get_ga_data
    # profile_id=params[:profile_id],
    # _start=params[:start],
    # _end=params[:end],
    # metrics=params[:metrics].split(','),
    # dimensions=nil,
    # params[:dimensions].split(',') if params[:dimensions]
    # # sort=params[:sort]||nil,
    # filters=params[:filters]||nil,
    # segment=params[:segment]||nil,
    # start_index=params[:start_index]||nil


    # to json string
    #
    # http://localhost:3000/get_ga_data?query_json={\"profile_id\":\"154710634\",\"start\":\"2017-12-30\",\"end\":\"2018-01-05\",\"metrics\":[\"ga:sessions\",\"ga:transactions\",\"ga:transactionRevenue\"],\"dimensions\":[\"ga:date\",\"ga:hour\",\"ga:userAgeBracket\"],\"filters\":\"ga:eventCategory==按鈕;ga:eventAction==點擊;ga:eventLabel=~點擊確認送出 - 進入付費頁面\",\"segment\":\"sessions::condition::ga:deviceCategory==tablet,ga:deviceCategory==desktop\",\"start_index\":1}
    # http://localhost:3000/get_ga_data
    # $.post( "http://localhost:3000/get_ga_data", {"profile_id":"154710634","start":"2017-12-30","end":"2018-01-05","metrics":["ga:sessions","ga:transactions","ga:transactionRevenue"],"dimensions":["ga:date","ga:hour","ga:userAgeBracket"],"filters":"ga:eventCategory==按鈕;ga:eventAction==點擊;ga:eventLabel=~點擊確認送出 - 進入付費頁面","segment":"sessions::condition::ga:deviceCategory==tablet,ga:deviceCategory==desktop","start_index":1}, function( data ) { console.log( data ); });

# {
#   "profile_id":"154710634",
#   "start":"2017-12-30",
#   "end":"2018-01-05",
#   "metrics":[
#     "ga:sessions",
#     "ga:transactions",
#     "ga:transactionRevenue"
#   ],
#   "dimensions":[
#     "ga:date",
#     "ga:hour",
#     "ga:userAgeBracket"
#   ],
#   "filters":"ga:eventCategory==按鈕;ga:eventAction==點擊;ga:eventLabel=~點擊確認送出 - 進入付費頁面",
#   "segment":"sessions::condition::ga:deviceCategory==tablet,ga:deviceCategory==desktop",
#   "start_index":1
# }

    u = User.where(email: "analytics@turingdigital.com.tw").first
    ana = Analytics.new(u)
    # ana.get_ga_data(
    #   profile_id,
    #   _start,
    #   _end,
    #   metrics,
    #   dimensions,
    #   nil, #sort,
    #   filters,
    #   segment,
    #   start_index,
    # )
    logger.debug(params)
    if params[:query_json].nil?
      result = ana.get_ga_data(
        params[:profile_id],
        params[:start],
        params[:end],
        params[:metrics].split(','),
        (params[:dimensions].nil? || params[:dimensions].empty?) ? nil : params[:dimensions].split(','),
        params[:sort],
        params[:filters].nil? || params[:filters].empty? ? nil : params[:filters],
        params[:segment].nil? || params[:segment].empty? ? nil : params[:segment],
        params[:start_index].nil? || params[:start_index].empty? ? nil : params[:start_index]
      )
      render json: result.to_json
    else
      result = ana.get_ga_data(
        params[:query_json][:profile_id],
        params[:query_json][:start],
        params[:query_json][:end],
        params[:query_json][:metrics].split(','),
        params[:query_json][:dimensions].nil? || params[:query_json][:dimensions].empty? ? nil : params[:query_json][:dimensions].split(','),
        params[:query_json][:sort],
        params[:query_json][:filters].nil? || params[:query_json][:filters].empty? ? nil : params[:query_json][:filters],
        params[:query_json][:segment].nil? || params[:query_json][:segment].empty? ? nil : params[:query_json][:segment],
        params[:query_json][:start_index].nil? || params[:query_json][:start_index].empty? ? nil : params[:query_json][:start_index]
      )

      render json: result.to_json
    end
  end
end
