class AddMidiumToUrlBuilders < ActiveRecord::Migration
  def change
    add_reference :url_builders, :campaign_medium, index: true, foreign_key: true
  end
end
