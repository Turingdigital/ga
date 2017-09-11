class SstainanController < ApplicationController

  def index
    @analytics = Analytics.new current_user
    profile_id = "147896085" # 妳好南搞

    all_data = []
    start_index = 1
    start_date = params["start_date"]||"7daysAgo"
    end_date = params["end_date"]||"yesterday"
    result = @analytics.sstainan(profile_id, start_date, end_date)
    pageview = @analytics.sstainan_pageview(profile_id, start_date, end_date)
    pageview = pageview["rows"]
    map = {}
    pageview.each {|p| map[p.first]= {pv: p[1]} }
    loop do
      break if result["rows"].nil?

      all_data.concat(result["rows"])
      break if result["rows"].size < 1000

      start_index += 1000
      result = @analytics.sstainan(profile_id, "7daysAgo", "yesterday", start_index)
    end
    all_data.each do |d|
      # byebug
      if map[d[1]]# && map[d[1]][d[0]]
        map[d[1]][d[0]] =d[2]
      end
      # break
    end

    @ok = map
    @ok.delete_if do |k, m|
      (k=~/customize_changeset_uuid|post_type|admin/) || m[:pv].nil?||m["25%"].nil?||m["50%"].nil?||m["75%"].nil?||m["100%"].nil? || (m[:pv].to_i==0)||(m["25%"].to_i==0)||(m["50%"].to_i==0)||(m["75%"].to_i==0)||(m["100%"].to_i==0)
    end

    # csv = "列標籤,PV,25%,50%,75%,100%,總計,到50%的留存率,到75%的留存率\n"
    # map.each do |k, m|
    #   if m[:pv]&&m["25%"]&&m["50%"]&&m["75%"]&&m["100%"]
    #     csv << "#{k},#{m[:pv]},#{m["25%"]},#{m["50%"]},#{m["75%"]},#{m["100%"]}\n"
    #   end
    # end
    # byebug
  end
end
