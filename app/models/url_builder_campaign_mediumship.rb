class UrlBuilderCampaignMediumship < ActiveRecord::Base
  belongs_to :url_builder
  belongs_to :campaign_medium
end
