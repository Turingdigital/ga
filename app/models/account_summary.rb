class AccountSummary < ActiveRecord::Base
  belongs_to :user

  class << self
    def fetch user
      analytics = Analytics.new user
      result = analytics.accountSummaries
      self.create(user: user, jsonString: result.to_json) if result
    end
  end
end
