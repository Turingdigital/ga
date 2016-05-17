class UrlBuildersController < ApplicationController
  before_action :set_url_builder, only: [:show, :edit, :update, :destroy]
  before_action :set_campaign_media, only: [:new, :edit]

  before_action :authorize, only: [:show, :edit, :new, :index]

  def schedule
    render :text => "ok"
    UrlBuilder.fetch_and_save_short_url_analytics_all
  end

  # GET /url_builders
  # GET /url_builders.json
  def index
    @url_builders = current_user.url_builders#UrlBuilder.all
  end

  # GET /url_builders/1
  # GET /url_builders/1.json
  def show
    redirect_to @url_builder.short_url_info
  end

  # GET /url_builders/new
  def new
    @url_builder = UrlBuilder.new
  end

  # GET /url_builders/1/edit
  def edit
  end

  # POST /url_builders
  # POST /url_builders.json
  def create
    params = url_builder_params
    params["start_date"] = Date.strptime(params["start_date"], "%m/%d/%Y")
    params["end_date"] = Date.strptime(params["end_date"], "%m/%d/%Y")

    @url_builder = UrlBuilder.new(params)
    @url_builder.user = current_user

    respond_to do |format|
      if @url_builder.save
        format.html { redirect_to @url_builder, notice: 'Url builder was successfully created.' }
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
    respond_to do |format|
      if @url_builder.update(url_builder_params)
        format.html { redirect_to @url_builder, notice: 'Url builder was successfully updated.' }
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
      redirect_to root_path unless current_user
    end
end
