class CreateAccountSummaries < ActiveRecord::Migration
  def change
    create_table :account_summaries do |t|
      t.references :user, index: true, foreign_key: true
      t.string :jsonString

      t.timestamps null: false
    end
  end
end
