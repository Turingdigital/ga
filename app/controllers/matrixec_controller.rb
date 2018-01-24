class MatrixecController < ApplicationController
  def index
    @account_summaries = AccountSummary.select(:id, :default_web_property).where(user: current_user)
    sign_in(User.find(4)) if Rails.env.development? && !user_signed_in?
  end

  def post
    sign_in(User.find(4)) if Rails.env.development? && !user_signed_in?
    @analytics = AnalyticsMatrixec.new current_user

    _11_file_name = "/csv/baw/baw_11_#{Time.now.to_i}.csv"
    _11(_11_file_name)

    # redirect_to _11_file_name
  end

  def _11 file_name
    profile_id = params[:matrixec][:profile_id]
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

    results.each do |result|
      result["rows"].each do|row|
        Matrixec11.create(
          date:row[0],
          hour:row[1],
          age:row[2],
          sessions:row[3].to_i,
          transactions:row[4].to_i,
          revenue:row[5].to_f,
          ct:row[-2].to_f==0 ? 0 : row[-1].to_f/row[-2].to_f
        )
      end
    end
    byebug


    # rows = []
    # table_1 = {}
    # table_2 = {}
    # table_3 = {}
    # dates = []
    # data = nil
    # results.each do |result|
    #   result["rows"].each {|row|
    #     # row[1] = "'#{row[1]}"
    #     # ["Date", "Hour", "Age", "Sessions","Transactions", "Revenue", "CustomerTransaction"]
    #     p_u = row[-2].to_f==0 ? 0 : row[-1].to_f/row[-2].to_f
    #     rows << row.push(p_u)
    #
    #     dates << row[0] unless dates.include?(row[0])
    #
    #     table_1[row[2]] = {} if table_1[row[2]].nil?
    #     table_1[row[2]][row[1]] = {} if table_1[row[2]][row[1]].nil?
    #     table_1[row[2]][row[1]][row[0]] = row[4]
    #
    #     table_2[row[0]] = {} if table_2[row[0]].nil?
    #     table_2[row[0]][row[1]] = 0 if table_2[row[0]][row[1]].nil?
    #     table_2[row[0]][row[1]] += row[4].to_i
    #
    #     table_3[row[0]] = {} if table_3[row[0]].nil?
    #     table_3[row[0]][row[1]] = 0 if table_3[row[0]][row[1]].nil?
    #     table_3[row[0]][row[1]] += row[5].to_f
    #   }
    #   data = {
    #     "小時熱點年齡" => ->(table_1) {
    #       re_all = [["",""].concat(dates)<<"總和"]
    #       ["18-24","25-34","35-44","45-54","55-64","65+"].each {|age|
    #         sum_date = {}
    #         ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23"].each {|hour|
    #           re_age_hour = [age, hour]
    #           sum_hour = 0
    #           dates.each {|date|
    #             begin
    #               re_age_hour << table_1[age][hour][date]
    #               sum_hour += table_1[age][hour][date].to_i
    #               sum_date[date] = 0 if sum_date[date].nil?
    #               sum_date[date] += table_1[age][hour][date].to_i
    #               # sum_date += table_1[age][hour][date].to_i
    #             rescue
    #               re_age_hour << "0"
    #             end
    #           }
    #           re_age_hour << sum_hour
    #           re_all << re_age_hour
    #         }
    #         re_all << (["#{age} 總計", ""].concat(sum_date.values))
    #       }
    #
    #       # table_1.each{|age, v1|
    #       #   ree = [[age]].concat(Array.new(v1.size-1) {[""]})
    #       #   i = 0
    #       #   v1.each {|hour, v2|
    #       #     ree[i] << hour
    #       #     v2.each {|date, v3|
    #       #       ree[i] << v3
    #       #     }
    #       #     i+=1
    #       #     byebug if Rails.env.development?
    #       #     break #if i>5
    #       #   }
    #       #   re << ree
    #       # }
    #       # re << []
    #
    #
    #       # byebug if _DEBUG
    #       # _DEBUG = false
    #       # table_1
    #       # byebug if Rails.env.development?
    #       return re_all
    #     }.call(table_1)
    #   }
    # end
    # filename = Rails.root+"public/xls/圖靈#{Time.now.to_f}-小時熱點報表.xls"
    # write_xls filename, data
  end

  def write_xls filename, data #{sheet_name_1: [rows...], sheet_name_2: [rows...], ...}
    book = Spreadsheet::Workbook.new

    # book = Spreadsheet.open Rails.root+"publick"+file_name
    data.each do |k, ary|
      sheet = book.create_worksheet
      i = 0
      ary.each do |row|
        sheet.row(i).replace(row)
        i += 1
        # byebug if Rails.env.development?
        # break if i > 5
      end
    end

    # @time_now = Time.now.to_f
    # filename = Rails.root+"public/csv/圖靈#{date_str}-MYDAY未註冊會員報表.xls"
    book.write(filename)
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
