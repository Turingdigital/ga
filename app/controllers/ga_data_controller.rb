class GaDataController < ApplicationController
  before_action :set_ga_datum, only: [:show, :edit, :update, :destroy]

  # GET /ga_data
  # GET /ga_data.json
  def index
    @ga_data = GaDatum.all
  end

  # GET /ga_data/1
  # GET /ga_data/1.json
  def show
  end

  # GET /ga_data/new
  def new
    @ga_datum = GaDatum.new
  end

  # GET /ga_data/1/edit
  def edit
  end

  # POST /ga_data
  # POST /ga_data.json
  def create
    @ga_datum = GaDatum.new(ga_datum_params)

    respond_to do |format|
      if @ga_datum.save
        format.html { redirect_to @ga_datum, notice: 'Ga datum was successfully created.' }
        format.json { render :show, status: :created, location: @ga_datum }
      else
        format.html { render :new }
        format.json { render json: @ga_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ga_data/1
  # PATCH/PUT /ga_data/1.json
  def update
    respond_to do |format|
      if @ga_datum.update(ga_datum_params)
        format.html { redirect_to @ga_datum, notice: 'Ga datum was successfully updated.' }
        format.json { render :show, status: :ok, location: @ga_datum }
      else
        format.html { render :edit }
        format.json { render json: @ga_datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ga_data/1
  # DELETE /ga_data/1.json
  def destroy
    @ga_datum.destroy
    respond_to do |format|
      format.html { redirect_to ga_data_url, notice: 'Ga datum was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ga_datum
      @ga_datum = GaDatum.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ga_datum_params
      params.require(:ga_datum).permit(:ga_label_id, :profile, :json)
    end
end
