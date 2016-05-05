class CreateUrlBuilderCampaignMediumships < ActiveRecord::Migration
  def change
    create_table :url_builder_campaign_mediumships do |t|
      t.references :url_builder, index: true, foreign_key: true
      t.references :campaign_medium, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
