class MatrixecController < ApplicationController
  def index
    @account_summaries = AccountSummary.select(:id, :default_web_property).where(user: current_user)
    sign_in(User.find(4)) if Rails.env.development? && !user_signed_in?

    @reports = -> {
      # (1..20).to_a.map {|n| {tag: "_#{n}", name: "_#{n}"}}
      [
        {tag: "_01", name: "網站基本概覽"},
        {tag: "_02_1", name: "裝置使用比較"},
        {tag: "_02_2", name: "裝置作業系統"},
        {tag: "_03", name: "性別年齡層比較"},
        {tag: "_03_2", name: "年齡層比 "},
        {tag: "_03_1", name: "性別比"},
        {tag: "_05", name: "來源/媒介帶來的轉換比較"},
        {tag: "_11", name: "小時熱點"},
        {tag: "_12", name: "波士頓矩陣"},
      ]
    }.call
  end

  def post
    sign_in(User.find(4)) if Rails.env.development? && !user_signed_in?
    @analytics = AnalyticsMatrixec.new current_user

    _start = params[:matrixec][:start_date]
    _end = params[:matrixec][:end_date]

    filenames = []
    # byebug
    params[:matrixec][:report].each{|tag, v|
      next if v=="0"
      # next if tag!="_11" && tag!="_02_1" && tag!="_02_2"
      # byebug

      filename = "report_#{tag.to_s}__#{_start}_to_#{_end}_#{Time.now.to_f}.xls"
      filenames << filename

      tag_dispatch tag, filename
      # puts "#{k}: #{v}"

      # _11_filename = "report_11#{Time.now.to_f}.xls"
      # _11(_11_filename)
      # redirect_to "/xls/#{_11_filename}"
      # break
    }

    # book.write(Rails.root+"public/xls/#{filename}")
    zip_filename = "compressed_#{Time.now.to_f}.zip"
    `zip -j #{Rails.root+"public/xls/#{zip_filename}"} #{filenames.map{|s| Rails.root+"public/xls/#{s}"}.join(' ')}`

    com_name = AccountSummary.find_com_name_by_profile(params[:matrixec][:profile_id], current_user)
    drive = Drive.instance
    filenames.each {|s|
      if( _start.include?('-'))
        drive.add(s, com_name, _start.match(/(\d+)-/)[1], _start.match(/-(\d+)-/)[1])
      else
        drive.add(s, com_name, _start[0..3], _start[4..5])
      end
    }

    # redirect_to "/xls/#{zip_filename}"

    # byebug
    redirect_to methods: index
  end

  def tag_dispatch tag, filename
    profileid = params[:matrixec][:profile_id]
    _start = params[:matrixec][:start_date]
    _end = params[:matrixec][:end_date]

    case tag
    when "_02_1"
      _02_1 filename, profileid, _start, _end
    when "_02_2"
      _02_2 filename, profileid, _start, _end
    when "_03_1"
      _03_1 filename, profileid, _start, _end
    when "_03_2"
      _03_2 filename, profileid, _start, _end
    when "_03"
      _03 filename, profileid, _start, _end
    when "_05"
      _05 filename, profileid, _start, _end
    when "_11"
      _11 filename, profileid, _start, _end
    end
  end

  def parse_02_data ana_data
    data = {
      "裝置使用比較" => -> {
        result = ana_data["rows"]
        result << [
          "",
          ana_data["totals_for_all_results"]["ga:sessions"],
          ana_data["totals_for_all_results"]["ga:percentNewSessions"],
          ana_data["totals_for_all_results"]["ga:newUsers"],
          ana_data["totals_for_all_results"]["ga:bounceRate"],
          ana_data["totals_for_all_results"]["ga:pageviewsPerSession"],
          ana_data["totals_for_all_results"]["ga:avgSessionDuration"],
          ana_data["totals_for_all_results"]["ga:transactions"],
          ana_data["totals_for_all_results"]["ga:transactionRevenue"],
          ana_data["totals_for_all_results"]["ga:transactionsPerSession"],
        ]
        result.each {|rst|
          [2,4,5,9].each {|idx| rst[idx] = "#{"%.2f" % rst[idx]}"}
          [2,4,9].each {|idx| rst[idx] = "#{"%.2f" % rst[idx]}%"}
          [6].each {|idx| rst[idx] = Time.at(rst[idx].to_f).utc.strftime("%H:%M:%S")}
          # rst[2] = "#{"%.2f" % result[idx][2]}%"
          # rst[4] = "#{"%.2f" % result[idx][4]}%"
        }
        result.unshift %w(裝置類別	工作階段	%新工作階段	新使用者	跳出率	單次工作階段頁數 平均工作階段時間長度	交易次數	收益	電子商務轉換率)
        return result
      }.call
    }
  end
  def _02_1 filename, profileid, _start, _end
    ana_data = @analytics._02_1(profileid, _start, _end)
    data = parse_02_data ana_data
    write_xls filename, data
  end
  def _02_2 filename, profileid, _start, _end
    ana_data = @analytics._02_2(profileid, _start, _end)
    data = parse_02_data ana_data
    write_xls filename, data
  end

  def parse_03_data ana_data
    data = {
      "性別年齡層比較" => -> {
        result = ana_data["rows"]
        result << [
          "",
          ana_data["totals_for_all_results"]["ga:users"],
          ana_data["totals_for_all_results"]["ga:newUsers"],
          ana_data["totals_for_all_results"]["ga:sessions"],
          ana_data["totals_for_all_results"]["ga:bounceRate"],
          ana_data["totals_for_all_results"]["ga:pageviewsPerSession"],
          ana_data["totals_for_all_results"]["ga:avgSessionDuration"],
        ]
        result.each {|rst|
          [4,5].each {|idx| rst[idx] = "#{"%.2f" % rst[idx]}"}
          [4].each {|idx| rst[idx] = "#{"%.2f" % rst[idx]}%"}
          [6].each {|idx| rst[idx] = Time.at(rst[idx].to_f).utc.strftime("%H:%M:%S")}
          # rst[2] = "#{"%.2f" % result[idx][2]}%"
          # rst[4] = "#{"%.2f" % result[idx][4]}%"
        }
        result.unshift %w(性別	使用者	新使用者	工作階段	跳出率	單次工作階段頁數	平均工作階段時間長度	圖靈_預訂步驟(目標5轉換率)	圖靈_預訂步驟(目標5達成)	圖靈_預訂步驟(目標5價值))
        return result
      }.call
    }
  end
  def _03_1 filename, profileid, _start, _end
    ana_data = @analytics._03_1(profileid, _start, _end)
    data = parse_03_data ana_data
    write_xls filename, data
  end
  def _03_2 filename, profileid, _start, _end
    ana_data = @analytics._03_2(profileid, _start, _end)
    data = parse_03_data ana_data
    write_xls filename, data
  end
  def _03 filename, profileid, _start, _end
    ana_data = @analytics._03(profileid, _start, _end)
    data = {
      "性別年齡層比較" => -> {
        result = ana_data["rows"]
        # result << [
        #   "",
        #   ana_data["totals_for_all_results"]["ga:sessions"],
        #   ana_data["totals_for_all_results"]["ga:bounceRate"],
        #   ana_data["totals_for_all_results"]["ga:avgSessionDuration"],
        #   ana_data["totals_for_all_results"]["ga:pageviewsPerSession"],
        # ]
        # byebug
        result.each {|rst|
          [4,6].each {|idx| rst[idx] = "#{"%.2f" % rst[idx]}"}
          [4].each {|idx| rst[idx] = "#{"%.2f" % rst[idx]}%"}
          [5].each {|idx| rst[idx] = Time.at(rst[idx].to_f).utc.strftime("%H:%M:%S")}

        }
        result.unshift %w(年齡層	性別	使用者類型	工作階段	跳出率	平均工作階段時間長度	單次工作階段頁數)
        return result
      }.call
    }
    write_xls filename, data
  end

  def _05 filename, profileid, _start, _end
    ana_data = @analytics._05(profileid, _start, _end)
    data = {
      "來源_媒介帶來的轉換比較" => -> {
        result = ana_data["rows"]
        result << [
          "",
          ana_data["totals_for_all_results"]["ga:sessions"],
          ana_data["totals_for_all_results"]["ga:percentNewSessions"],
          ana_data["totals_for_all_results"]["ga:newUsers"],
          ana_data["totals_for_all_results"]["ga:bounceRate"],
          ana_data["totals_for_all_results"]["ga:pageviewsPerSession"],
          ana_data["totals_for_all_results"]["ga:avgSessionDuration"],
          ana_data["totals_for_all_results"]["ga:transactions"],
          ana_data["totals_for_all_results"]["ga:transactionRevenue"],
        ]
        result.each {|rst|
          rst.insert(7, 0.0)
          [2,4,5,7].each {|idx| rst[idx] = "#{"%.2f" % rst[idx]}"}
          [2,7].each {|idx| rst[idx] = "#{"%.2f" % rst[idx]}%"}
          [6].each {|idx| rst[idx] = Time.at(rst[idx].to_f).utc.strftime("%H:%M:%S")}

        }
        result.unshift %w( 來源/媒介	工作階段	%新工作階段	新使用者	跳出率	單次工作階段頁數	平均工作階段時間長度	電子商務轉換率	交易次數	收益)
        return result
      }.call
    }
    write_xls filename, data
  end

  def _11 filename, profileid, _start, _end
    # profile_id = params[:matrixec][:profile_id]
    # profileid = profile_id
    profile_id = profileid
    # _start = params[:matrixec][:start_date]
    # _end = params[:matrixec][:end_date]
    results = []
    result = @analytics._11(profile_id, _start, _end)
    # file_name = "/xls/11.xlsx"

    # result = @analytics.myday_sitemap(profile_id, _start, _end, 1)
    # result = @analytics.myday_sitemap(profile_id, _start, _end, 233001, host)
    total_results = result['total_results']
    results << result
    # create_url_by result, _start, _end, host, 1

    if total_results > 1000
      1001.step(total_results, 1000) do |n|
        results <<  @analytics._11(profile_id, _start, _end, n)
      end
    end

    # date:string
    # hour:string
    # age:string
    # sessions:integer
    # transactions:integer
    # revenue:float
    # ct:float

    # if false
      Matrixec11.transaction{
        # Matrixec11.destroy_all
        results.each do |result|
          result["rows"].each do|row|
            Matrixec11.create(
              date:row[0],
              hour:row[1],
              age:row[2],
              sessions:row[3].to_i,
              transactions:row[4].to_i,
              revenue:row[5].to_f,
              ct:(row[-2].to_f==0 ? 0 : row[-1].to_f/row[-2].to_f),
              profileid:profileid
            )
          end unless result["rows"].nil?
        end
      }
    # end

    # 為了在資料庫裡面搜尋
    _start.gsub!('-', '')
    _end.gsub!('-', '')

# rails g migration add_column_profileid_to_matrixec profileid:string:index
    data = {
      "小時熱點年齡" => -> {
        result = [["加總 - 交易次數"],["列標籤", Matrixec11.dates(profileid, _start, _end), "總計"].flatten]
        Matrixec11.ages(profileid, _start, _end).each do |age|
          result << [age]

          age_total = 0
          [ "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12",
            "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23" ].each do |hour|
              transactions_array = Matrixec11.transactions_array(profileid, _start, _end, hour, age)
              transactions_array_sum = transactions_array.sum
              result << [hour, transactions_array, transactions_array.sum].flatten
              age_total += transactions_array_sum
          end

          result << ["#{age} 合計"]
          Matrixec11.dates(profileid, _start, _end).each do |date|
            result.last << Matrixec11.sum_date_transactions(profileid, date, age)
          end
          result.last << age_total
        end
        return result
      }.call,
      "小時熱點交易數" => -> {
        result = [["加總 - 交易次數"],["列標籤", Matrixec11.dates(profileid, _start, _end), "總計"].flatten]

        total = 0
        [ "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12",
          "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23" ].each do |hour|
            transactions_array = Matrixec11.transactions_array(profileid, _start, _end, hour)
            transactions_array_sum = transactions_array.sum
            result << [hour, transactions_array, transactions_array.sum].flatten
            total += transactions_array_sum
        end

        result << ["總計"]
        Matrixec11.dates(profileid, _start, _end).each do |date|
          result.last << Matrixec11.sum_date_transactions(profileid, date)
        end
        result.last << total

        return result
      }.call,
      "小時熱點交易金額" => -> {
        result = [["加總 - 產品收益"],["列標籤", Matrixec11.dates(profileid, _start, _end), "總計"].flatten]

        total = 0
        [ "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12",
          "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23" ].each do |hour|
          # ["17"].each do |hour|
            revenue_array = Matrixec11.revenue_array(profileid, _start, _end, hour)
            revenue_array_sum = revenue_array.sum
            result << [hour, revenue_array, revenue_array.sum].flatten
            total += revenue_array_sum
        end

        result << ["總計"]
        Matrixec11.dates(profileid, _start, _end).each do |date|
          result.last << Matrixec11.sum_date_revenue(profileid, date)
        end
        result.last << total

        return result
      }.call
    }
    # byebug
    # filename = "report_11#{Time.now.to_f}.xls"
    write_xls filename, data
  end

  def write_xls filename, data #{sheet_name_1: [rows...], sheet_name_2: [rows...], ...}
    book = Spreadsheet::Workbook.new
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

  def write_csv
    CSV.open(Rails.root+"public#{file_name}", "wb") do |csv|
      csv << ["Date", "Hour", "Age", "Sessions","Transactions", "Revenue", "CustomerTransaction"]
      rows.each {|row| csv << row}
      # results.each do |result|
      #   result["rows"].each {|row|
      #     # row[1] = "'#{row[1]}"
      #     p_u = row[-2].to_f==0 ? 0 : row[-1].to_f/row[-2].to_f
      #     csv << row.push(p_u)
      #   }
      # end
    end
  end
end
