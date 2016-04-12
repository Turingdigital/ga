class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(:email => data["email"]).first
    # Uncomment the section below if you want users to be created if they don't exist
    # <OmniAuth::AuthHash::InfoHash
    # email="isaac@adup.com.tw"
    # first_name="Issac"
    # image="https://lh5.googleusercontent.com/-797ynua4kN4/AAAAAAAAAAI/AAAAAAAAAAo/0IsO8gedqGo/photo.jpg"
    # last_name="Tsai"
    # name="Issac Tsai">
    unless user
      user = User.create(
      # name: data["name"],
      email: data["email"],
      # first_name: data["first_name"],
      # image: data["image"],
      # last_name: data["last_name"],
      # name: data["name"],
      password: Devise.friendly_token[0,20]
      )
    end
    # <OmniAuth::AuthHash::InfoHash
    # email="isaac@adup.com.tw"
    # first_name="Issac"
    # image="https://lh5.googleusercontent.com/-797ynua4kN4/AAAAAAAAAAI/AAAAAAAAAAo/0IsO8gedqGo/photo.jpg"
    # last_name="Tsai"
    # name="Issac Tsai">
    user
  end
end
