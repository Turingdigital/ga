class AddCloumnForAccountSummary < ActiveRecord::Migration
  def change
    add_column(:account_summaries, :default_profile, :integer)
  end
end
