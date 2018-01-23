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


    redirect_to _11_file_name
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

    # book = Spreadsheet.open Rails.root+"tmp#{file_name}"
    CSV.open(Rails.root+"public#{file_name}", "wb") do |csv|
      csv << ["Date", "Hour", "Age", "Transactions", "Revenue", "CustomerTransaction"]
        results.each do |result|
          result["rows"].each {|row|
            # row[1] = "'#{row[1]}"
            p_u = row[-2].to_f==0 ? 0 : row[-1].to_f/row[-2].to_f
            csv << row.push(p_u)
          }
        end
    end
  end
end
