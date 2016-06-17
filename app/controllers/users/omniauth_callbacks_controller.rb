# class CredentialsWemee
#   attr_accessor :client_id, :access_token, :refresh_token, :scope, :expiration_time_millis, :expires_at
#
#   def initialize client_id, access_token, refresh_token, scope, expires_at
#     @client_id = client_id
#     @access_token = access_token
#     @refresh_token = refresh_token
#     @scope = scope
#     @expiration_time_millis = expires_at*1000
#     @expires_at = @expiration_time_millis
#   end
# end

# require 'google/apis/analytics_v3'
# require 'googleauth'
# require 'googleauth/stores/redis_token_store'

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
      # You need to implement the method below in your model (e.g. app/models/user.rb)
      # session[:code]=params[:code]
      @user = User.from_omniauth(request.env["omniauth.auth"])

      ###
      # scope = Google::Apis::AnalyticsV3::AUTH_ANALYTICS
      # client_id = Google::Auth::ClientId.new('782362301580-bnlu7s7gmjv9htlh65837ufjes6ptd37.apps.googleusercontent.com', '2dZLlxRKmeSqT5QmAl6tOPXC')
      # cred = CredentialsWemee.new(
      #   '782362301580-bnlu7s7gmjv9htlh65837ufjes6ptd37.apps.googleusercontent.com',
      #   request.env["omniauth.auth"].credentials.token,
      #   request.env["omniauth.auth"].credentials.refresh_token,
      #   scope,
      #   request.env["omniauth.auth"].credentials.expires_at)
      #
      # token_store = Google::Auth::Stores::RedisTokenStore.new({redis: 'localhost', prefix: "ga_user_"})
      # authorizer = Google::Auth::UserAuthorizer.new(client_id, scope, token_store, 'http://localhost:3000/oauth/ga_callback')
      # authorizer.store_credentials('isaac@adup.com.tw', cred)
      ###

      # byebug
      if @user.persisted?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
        sign_in_and_redirect @user, :event => :authentication
      else
        session["devise.google_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
  end
end
