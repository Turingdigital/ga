Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, '782362301580-bnlu7s7gmjv9htlh65837ufjes6ptd37.apps.googleusercontent.com', '2dZLlxRKmeSqT5QmAl6tOPXC',
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

            #  :prompt => "select_account",
             :prompt => "consent",
            #  :image_aspect_ratio => "square",
            #  :image_size => 50
           }
  end
