class WelcomeController < ApplicationController
  layout false

  def index
    redirect_to user_user_path(current_user) if user_signed_in?
       #.account_summary if current_user.account_summary
  end
end

=begin
  無GA帳號錯誤訊息
{
 "error": {
  "errors": [
   {
    "domain": "global",
    "reason": "insufficientPermissions",
    "message": "User does not have any Google Analytics account."
   }
  ],
  "code": 403,
  "message": "User does not have any Google Analytics account."
 }
}
=end

# gem install bundler passenger --no-ri --no-rdoc
# /opt/nginx/sbin/nginx -g 'daemon off;'
#
# REDIS_NAME=/stupefied_morse/redis
#
# BUNDLE_SILENCE_ROOT_WARNING=1
# BUNDLE_APP_CONFIG=/usr/local/bundle
# REDIS_PORT_6379_TCP_ADDR 172.17.0.2
# passenger_env_var REDIS_PORT_6379_TCP_PORT 6379
# REDIS_ENV_GOSU_VERSION=1.7
#
# export GOOGLE_CLIENT_ID=782362301580-bnlu7s7gmjv9htlh65837ufjes6ptd37.apps.googleusercontent.com;
# export GOOGLE_CLIENT_SECRET=2dZLlxRKmeSqT5QmAl6tOPXC;
# export GOOGLE_API_KEY=AIzaSyD2WRzzla118fiEyom6nWML5Ob19FGtTfo;
