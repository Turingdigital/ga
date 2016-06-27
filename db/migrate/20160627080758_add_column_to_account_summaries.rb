class AddColumnToAccountSummaries < ActiveRecord::Migration
  def change
    add_column :account_summaries, :default_item, :string
    add_column :account_summaries, :default_web_property, :string
  end
end
