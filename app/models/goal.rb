class Goal < ActiveRecord::Base
  belongs_to :user

  def self.create_by_user_than_fetch_and_save user
    ana = Analytics.new user
    json = ana.list_goals.to_json
    self.create(user: user, json: json)
  end
end
