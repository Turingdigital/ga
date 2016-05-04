class WelcomeController < ApplicationController
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
