class AccountSummary < ActiveRecord::Base
  belongs_to :user

  def hash
    return JSON.parse self.jsonString
  end

  def default_ga_setting_names
    h = {item: find_item}
    h[:web_property] = find_web_property_from_item h[:item]
    h[:profile] = find_profile_from_web_property h[:web_property]
    return {item: h[:item]["name"], web_property: h[:web_property]["name"], profile: h[:profile]["name"]}
  end

  class << self

    def re_fetch user
      analytics = Analytics.new user
      result = analytics.accountSummaries
      if result
        ac = self.where(user: user)
        if ac.size > 0
          ac = ac.first
          ac.jsonString = result.to_json
          ac.save
        else
          self.create(user: user, jsonString: result.to_json)
        end
      end
    end

    def fetch user
      analytics = Analytics.new user
      result = analytics.accountSummaries
      self.create(user: user, jsonString: result.to_json) if result
    end
  end

  private
    def find_item
      return JSON.parse(self.jsonString)['items'].index_by{|item| item["id"]==self.default_item}[true]
    end

    def find_web_property_from_item item
      return item["web_properties"].index_by{|web_property| web_property["id"]==self.default_web_property}[true]
    end

    def find_profile_from_web_property web_property
      return web_property["profiles"].index_by{|profile| profile["id"]==self.default_profile}[true]
    end
end
