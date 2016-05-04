require 'google/apis/analytics_v3'

class GaCredential < ActiveRecord::Base
  belongs_to :user

  def client_id
    return ENV['GOOGLE_CLIENT_ID']
  end

  def scope
    return Google::Apis::AnalyticsV3::AUTH_ANALYTICS
  end

  def expiration_time_millis
    return self.expires_at * 1000
  end
end
