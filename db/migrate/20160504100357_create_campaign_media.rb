class CreateCampaignMedia < ActiveRecord::Migration
  def change
    create_table :campaign_media do |t|
      t.string :medium

      t.timestamps null: false
    end
  end
end
