require 'iconv'

class UrlBuildersController < ApplicationController
  before_action :set_url_builder, only: [:show, :edit, :update, :destroy, :duplicate]
  before_action :set_campaign_media, only: [:new, :edit]

  before_action :authorize, only: [:show, :edit, :new, :index]

  def schedule
    render :text => "ok"
    UrlBuilder.fetch_and_save_short_url_analytics_all
  end

  def duplicate
    @url_builder.dup.save
    redirect_to action: :index, notice: '複製完成，在最新的一筆'
  end

  def import_example
  end

  def import
    UrlBuilder.import(params[:file], current_user)
    redirect_to action: "index", notice: "匯入完成"
  end

  # GET /url_builders
  # GET /url_builders.json
  def index
    @url_builders = current_user.url_builders.order(id: :desc)#UrlBuilder.all

    #TODO 每天取一次就好 不要每次都取
    # @url_builders.each(&:fetch_and_save_short_url_analytics)
    @url_builders.each do |ub|
      ub.fetch_and_save_short_url_analytics if ub.url_analytics.empty?
    end

    ic = Iconv.new("big5", "utf-8")
    respond_to do |format|
      format.html
      format.csv {send_data(ic.iconv(send_csv(@url_builders)))} #{ send_data @url_builders.to_csv }
      # format.xls # { send_data @products.to_csv(col_sep: "\t") }
    end
  end

  def excel
    file_name = "TD_Url_Builders_#{Date.today.to_s}.xlsx"
    if false && File.exist?(Rails.root + "public/" + file_name)
      # redirect_to("http://td.turingdigital.com.tw/#{file_name}")
      send_file(Rails.root + "public/" + file_name, :type => "application/xlsx")
    else
      workbook = WriteXLSX.new(Rails.root + "public/" + file_name)
      worksheet = workbook.add_worksheet

      # worksheet.write(0, 0, "流水號")

      column_pos = 0

      # format23 = workbook.add_format(:bg_color => 23)
      # ["媒體","客戶名","廣告內容","位置/規格-鏈接至"].map.with_index{ |x, i|
      #   worksheet.write(0, column_pos, x, format23)
      #   column_pos += 1
      # }

      format17 = workbook.add_format(:bg_color => 17)
      ["活動地址URL",
      "*來源utm_source","*媒介utm_medium","*活動名稱utm_campaign",
      "搜索關鍵字utm_term","內容utm_content"].map.with_index{ |x, i|
        worksheet.write(0, column_pos, x, format17)
        column_pos += 1
      }

      format11 = workbook.add_format(:bg_color => 11)
      worksheet.write(0, column_pos, "最終URL", format11)
      column_pos += 1

      format12 = workbook.add_format(:bg_color => 12)
      worksheet.write(0, column_pos, "短網址區", format12)
      column_pos += 1

      ["短網址點擊成效","Google Analytics 報表成效","差異值"].map.with_index{ |x, i|
        worksheet.write(0, column_pos, x)
        column_pos += 1
      }

      @url_builders = current_user.url_builders.order(id: :desc)
      row = 1
      @url_builders.each do |ub|
        col = 0
        # worksheet.write(row, col, row)
        # col += 1
        # 4.times {
        #   worksheet.write(row, col, "-")
        #   col += 1
        # }
        worksheet.write(row, col, ub.url)
        col+=1
        worksheet.write(row, col, ub.source)
        col+=1
        worksheet.write(row, col, ub.campaign_medium.medium)
        col+=1
        worksheet.write(row, col, ub.name)
        col+=1
        worksheet.write(row, col, ub.term)
        col+=1
        worksheet.write(row, col, ub.content)
        col+=1

        worksheet.write(row, col, ub.builded_url)
        col+=1
        worksheet.write(row, col, ub.short_url)
        col+=1

        3.times {
          worksheet.write(row, col, "-")
          col += 1
        }

        row += 1
      end
      workbook.close

      #TODO: 偵測Excel檔是否成功，是否使用遞迴傳送檔案，不像現在重複程式碼
      send_file(Rails.root + "public/" + file_name, :type => "application/xlsx")
      # redirect_to("http://td.turingdigital.com.tw/#{file_name}")
    end
  end

  def csv_utf8
    @url_builders = current_user.url_builders.order(id: :desc)
    respond_to do |format|
      format.csv {send_data(send_csv(@url_builders))}
    end
  end

  # TODO: 這邊先Drity Hack，需重構到Model裡面
  def send_csv url_builders
    csv_string = CSV.generate() do |csv|
      csv << ["流水號","媒體","客戶名","廣告內容","位置/規格-鏈接至",

      "活動地址URL",
      "*來源utm_source","*媒介utm_medium","*活動名稱utm_campaign",
      "搜索關鍵字utm_term","內容utm_content",

      "最終URL",
      "短網址區",
      "短網址點擊成效","Google Analytics 報表成效","差異值"]

      cnt=0
      csv_string = url_builders.each do |ub|
        csv << [cnt+=1,"媒體","客戶名","廣告內容","位置/規格-鏈接至",
          ub.url,
          ub.source,ub.campaign_medium.medium,ub.name,
          ub.term,ub.content,

          ub.builded_url,
          ub.short_url,
          "短網址點擊成效","Google Analytics 報表成效","差異值"]
      end
    end
    return csv_string
  end

  # GET /url_builders/1
  # GET /url_builders/1.json
  def show
    redirect_to @url_builder.short_url_info
  end

  # GET /url_builders/new
  def new
    target = @campaign_media.where(user: current_user)
    unless target.empty?
      target = target.order(created_at: :desc).first
      @campaign_media.delete target
      @campaign_media = @campaign_media.to_a
      @campaign_media.unshift target
    end

    @url_builder = UrlBuilder.new
  end

  # GET /url_builders/1/edit
  def edit
  end

  # POST /url_builders
  # POST /url_builders.json
  def create
    params = url_builder_params
    parse_params_date params

    @url_builder = UrlBuilder.new(params)
    @url_builder.user = current_user
    @url_builder.profile = user.account_summary.default_profile

    respond_to do |format|
      if @url_builder.save
        format.html { redirect_to action: :index, notice: 'Url builder was successfully created.' }
        format.json { render :show, status: :created, location: @url_builder }
      else
        format.html { render :new }
        format.json { render json: @url_builder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /url_builders/1
  # PATCH/PUT /url_builders/1.json
  def update
    params = url_builder_params
    parse_params_date params

    respond_to do |format|
      if @url_builder.update(params)
        # format.html { redirect_to @url_builder, notice: 'Url builder was successfully updated.' }
        format.html { redirect_to action: :index, notice: 'Url builder was successfully updated.' }
        format.json { render :show, status: :ok, location: @url_builder }
      else
        format.html { render :edit }
        format.json { render json: @url_builder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /url_builders/1
  # DELETE /url_builders/1.json
  def destroy
    @url_builder.destroy
    respond_to do |format|
      format.html { redirect_to url_builders_url, notice: 'Url builder was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def parse_params_date params
      params["start_date"] = Date.strptime(params["start_date"], "%Y-%m-%d") unless params["start_date"]==""
      params["end_date"] = Date.strptime(params["end_date"], "%Y-%m-%d") unless params["end_date"]==""
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_url_builder
      @url_builder = UrlBuilder.find(params[:id])
    end

    def set_campaign_media
      @campaign_media = CampaignMedium.all
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def url_builder_params
      params.require(:url_builder).permit(:user_id, :url, :source, :campaign_medium_id, :term, :content, :name, :start_date, :end_date)
    end

    def authorize
      if user_signed_in?
        if current_user.account_summary.default_profile.nil?
          redirect_to(account_summary_url(current_user.account_summary), flash: {alert: "你尚未設定預設設定檔"})
        end
      else
        redirect_to root_path
      end
    end
end
