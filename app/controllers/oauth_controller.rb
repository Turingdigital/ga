class OauthController < ApplicationController
  def ga_callback
    byebug
    redirect_to current_user
  end
end
