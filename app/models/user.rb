class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]

  has_one :account_summary
  has_one :ga_credential

  def fetch_account_summary
    # return self.account_summary ? self.account_summary : AccountSummary.fetch(self, code)
    AccountSummary.fetch(self)
  end

  # def update_account_summary
  # end

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
    user.update_or_create_ga_credentials(
      access_token.credentials.token,
      access_token.credentials.refresh_token,
      access_token.credentials.expires_at)

    user.reload_authorizer_store_credentials_from_model

    return user
  end

  def reload_authorizer_store_credentials_from_model
    ana = Analytics.new self
    ana.reload_authorizer_store_credentials_from_model
  end

  def update_or_create_ga_credentials access_token, refresh_token, expires_at
    if self.ga_credential
      self.ga_credential.access_token = access_token
      self.ga_credential.refresh_token = refresh_token
      self.ga_credential.expires_at = expires_at
      self.ga_credential.save
    else
      GaCredential.create(
        access_token: access_token,
        refresh_token: refresh_token,
        expires_at: expires_at,
        user: self
      )
      # byebug
    end
  end

end
