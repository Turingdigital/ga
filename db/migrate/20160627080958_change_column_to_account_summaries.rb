class ChangeColumnToAccountSummaries < ActiveRecord::Migration
  def change
    change_column(:account_summaries, :default_profile, :string) 
  end
end
