class ChangeColumnForAccountSummary < ActiveRecord::Migration
  def change
    change_column(:account_summaries, :jsonString, :text)
  end
end
