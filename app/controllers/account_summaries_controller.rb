class AccountSummariesController < ApplicationController
  before_action :set_account_summary, only: [:show, :edit, :update, :destroy, :setup_profile]
  before_action :set_profile, only: [:setup_profiles]
  before_action :check_user_signed_in

  def default_profile?
    return !self.default_profile.nil?
  end

  def setup_profile
    @account_summary.default_profile = params[:profile]

    # 前端尚未比對是從哪個profile_id來的goal_id
    # goal_id = params[:id]
    # 尚未可以儲存預設的轉換目標
    # 考慮使用者可以在報表頁面切換，不像profile直接預設

    @account_summary.save
    redirect_to dashboard_path #action: :index
    # byebug
  end

  # GET /account_summaries
  # GET /account_summaries.json
  def index
    @account_summaries = AccountSummary.all
  end

  # GET /account_summaries/1
  # GET /account_summaries/1.json
  def show
    AccountSummary.re_fetch current_user
    # @goal_json = current_user.goal.json
  end

  # GET /account_summaries/new
  def new
    @account_summary = AccountSummary.new
  end

  # GET /account_summaries/1/edit
  def edit
  end

  # POST /account_summaries
  # POST /account_summaries.json
  def create
    @account_summary = AccountSummary.new(account_summary_params)

    respond_to do |format|
      if @account_summary.save
        format.html { redirect_to @account_summary, notice: 'Account summary was successfully created.' }
        format.json { render :show, status: :created, location: @account_summary }
      else
        format.html { render :new }
        format.json { render json: @account_summary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /account_summaries/1
  # PATCH/PUT /account_summaries/1.json
  def update
    respond_to do |format|
      if @account_summary.update(account_summary_params)
        format.html { redirect_to @account_summary, notice: 'Account summary was successfully updated.' }
        format.json { render :show, status: :ok, location: @account_summary }
      else
        format.html { render :edit }
        format.json { render json: @account_summary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /account_summaries/1
  # DELETE /account_summaries/1.json
  def destroy
    @account_summary.destroy
    respond_to do |format|
      format.html { redirect_to account_summaries_url, notice: 'Account summary was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account_summary
      @account_summary = AccountSummary.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_summary_params
      params.require(:account_summary).permit(:user_id, :jsonString)
    end

    def check_user_signed_in
      redirect_to root_path unless user_signed_in?
    end
end
