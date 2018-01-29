class MatrixecController < ApplicationController
  def index
    @account_summaries = AccountSummary.select(:id, :default_web_property).where(user: current_user)
    sign_in(User.find(4)) if Rails.env.development? && !user_signed_in?

    @reports = -> {
      # (1..20).to_a.map {|n| {tag: "_#{n}", name: "_#{n}"}}
      [{tag: "_11", name: "小時熱點"}]
    }.call
  end

  def post
    sign_in(User.find(4)) if Rails.env.development? && !user_signed_in?
    @analytics = AnalyticsMatrixec.new current_user

    filenames = []
    params[:matrixec][:report].each{|k, v|
      next if v==0

      # _11_filename = "report_11#{Time.now.to_f}.xls"
      # _11(_11_filename)
      filenames << "report#{k.to_s}#{Time.now.to_f}.xls"

      # puts "#{k}: #{v}"
    }

    # byebug
    # redirect_to "/xls/#{_11_filename}"
    redirect_to methods: index
  end

  def _11 filename
    profile_id = params[:matrixec][:profile_id]
    profileid = profile_id
    _start = params[:matrixec][:start_date]
    _end = params[:matrixec][:end_date]
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
