class UrlAnalytic < ActiveRecord::Base
  belongs_to :url_builder

  def allTime_shortUrlClicks
    JSON.parse(self.json)["analytics"]["allTime"]["shortUrlClicks"]
  end
end
