class CreateGaCampaigns < ActiveRecord::Migration
  def change
    create_table :ga_campaigns do |t|
      t.string :source
      t.string :medium
      t.date :date
      t.integer :sessions
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :ga_campaigns, :source
    add_index :ga_campaigns, :medium
    add_index :ga_campaigns, :date
  end
end
