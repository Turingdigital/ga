class UrlAnalytic < ActiveRecord::Base
  belongs_to :url_builder

  def allTime_shortUrlClicks
    begin
      return JSON.parse(self.json)["analytics"]["allTime"]["shortUrlClicks"]
    rescue

    end
    return 0
  end
end
