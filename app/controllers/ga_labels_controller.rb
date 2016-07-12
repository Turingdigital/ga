class GaLabelsController < ApplicationController
  before_action :set_ga_label, only: [:show, :edit, :update, :destroy]

  # GET /ga_labels
  # GET /ga_labels.json
  def index
    @ga_labels = GaLabel.all
  end

  # GET /ga_labels/1
  # GET /ga_labels/1.json
  def show
  end

  # GET /ga_labels/new
  def new
    @ga_label = GaLabel.new
  end

  # GET /ga_labels/1/edit
  def edit
  end

  # POST /ga_labels
  # POST /ga_labels.json
  def create
    @ga_label = GaLabel.new(ga_label_params)

    respond_to do |format|
      if @ga_label.save
        format.html { redirect_to @ga_label, notice: 'Ga label was successfully created.' }
        format.json { render :show, status: :created, location: @ga_label }
      else
        format.html { render :new }
        format.json { render json: @ga_label.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ga_labels/1
  # PATCH/PUT /ga_labels/1.json
  def update
    respond_to do |format|
      if @ga_label.update(ga_label_params)
        format.html { redirect_to @ga_label, notice: 'Ga label was successfully updated.' }
        format.json { render :show, status: :ok, location: @ga_label }
      else
        format.html { render :edit }
        format.json { render json: @ga_label.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ga_labels/1
  # DELETE /ga_labels/1.json
  def destroy
    @ga_label.destroy
    respond_to do |format|
      format.html { redirect_to ga_labels_url, notice: 'Ga label was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ga_label
      @ga_label = GaLabel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ga_label_params
      params.require(:ga_label).permit(:name)
    end
end
