class AddUserToCampaignMedium < ActiveRecord::Migration
  def change
    add_reference :campaign_media, :user, index: true, foreign_key: true
  end
end
