Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'],
           {
             :name => "google",
             access_type: 'offline',
             scope: 'https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/analytics.readonly',
            #  scope: 'email profile https://www.googleapis.com/auth/analytics.readonly',
            #  :scope => ["email",
            #             "profile",
            #             "https://www.googleapis.com/auth/analytics.readonly"],
            #  :scope => "profile analytics.readonly",
            #  :scope => "email profile",

             :prompt => "select_account",
            #  :image_aspect_ratio => "square",
            #  :image_size => 50
           }
  end
