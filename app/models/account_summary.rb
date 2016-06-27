class AccountSummary < ActiveRecord::Base
  belongs_to :user

  def hash
    return JSON.parse self.jsonString
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
end
