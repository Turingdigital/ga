class AccountSummary < ActiveRecord::Base
  belongs_to :user

  class << self
    def fetch user, code
      return self.where(user: user).size if self.where(user: user).size >= 1

      ana = Analytics.new user
      result = @analytics.list_account_summaries
      if result
        self.create(user: user, jsonString: "testing")
        return result
      end
      return false
    end
  end
end
