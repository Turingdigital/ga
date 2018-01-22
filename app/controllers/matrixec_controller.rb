class MatrixecController < ApplicationController
  def index
    @account_summaries = AccountSummary.select(:id, :default_web_property).where(user: current_user)
  end
end
