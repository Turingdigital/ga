class User::UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :refetch]

  def show

    if @user.account_summary
      # Goal.create_by_user_than_fetch_and_save @user if @user.goal.nil?
      redirect_to (@user.account_summary.default_profile? ? dashboard_path : @user.account_summary)
    else
      @user.fetch_account_summary
      redirect_to (@user.account_summary ? {action: :show} : {action: :noga})
    end

  end

  # 沒有申請過Google Analytics
  def noga
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit()
    end
end
