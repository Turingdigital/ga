class CampaignMedium < ActiveRecord::Base
  # has_many :url_builder_campaign_mediumships
  # has_many :url_builders, :through => :url_builder_campaign_mediumships
  has_one :url_builder
  belongs_to :user
end
