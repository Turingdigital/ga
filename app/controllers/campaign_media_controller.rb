class CampaignMediaController < ApplicationController
  before_action :set_campaign_medium, only: [:show, :edit, :update, :destroy]

  # GET /campaign_media
  # GET /campaign_media.json
  def index
    @campaign_media = CampaignMedium.all
  end

  # GET /campaign_media/1
  # GET /campaign_media/1.json
  def show
  end

  # GET /campaign_media/new
  def new
    @campaign_medium = CampaignMedium.new
  end

  # GET /campaign_media/1/edit
  def edit
  end

  # POST /campaign_media
  # POST /campaign_media.json
  def create
    @campaign_medium = CampaignMedium.new(campaign_medium_params)

    respond_to do |format|
      if @campaign_medium.save
        format.html { redirect_to @campaign_medium, notice: 'Campaign medium was successfully created.' }
        format.json { render :show, status: :created, location: @campaign_medium }
      else
        format.html { render :new }
        format.json { render json: @campaign_medium.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /campaign_media/1
  # PATCH/PUT /campaign_media/1.json
  def update
    respond_to do |format|
      if @campaign_medium.update(campaign_medium_params)
        format.html { redirect_to @campaign_medium, notice: 'Campaign medium was successfully updated.' }
        format.json { render :show, status: :ok, location: @campaign_medium }
      else
        format.html { render :edit }
        format.json { render json: @campaign_medium.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /campaign_media/1
  # DELETE /campaign_media/1.json
  def destroy
    @campaign_medium.destroy
    respond_to do |format|
      format.html { redirect_to campaign_media_url, notice: 'Campaign medium was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_campaign_medium
      @campaign_medium = CampaignMedium.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def campaign_medium_params
      params.require(:campaign_medium).permit(:medium)
    end
end
