Rails.application.routes.draw do
  resources :filters do
    collection do
      post 'setup'
    end
  end

  resources :ga_data
  resources :ga_labels
  resources :foos
  resources :campaign_media
  resources :url_builders do
    collection do
      get 'schedule'
      get 'csv_utf8'
      get 'excel'
      get 'import_example'
      post 'import'
      post 'import_url'
      post 'duplicate/:id', action: :duplicate
    end
  end
  resources :account_summaries do
    collection do
      post 'setup_profile'
      get :refetch
    end
  end

  namespace :user do
    resources :users do
      resources :url_builders, :controller => 'user_url_builders'
      collection do
        get :noga
      end
    end
  end
  resources :testings
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  get 'welcome/myjapan_auto' => 'welcome#myjapan_auto'
  get 'welcome/myday_b01' => 'welcome#myday_b01'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  get 'oauth/ga_callback' => 'oauth#ga_callback'

  get 'dashboard' => 'dashboard#index'
  get 'hotcar' => 'hotcar#index'
  get 'irent' => 'irent#index'
  get 'newgen' => 'newgen#index'
  get 'newgen/:y1/:m1' => 'newgen#index'
  get 'newgen/:y1/:m1/:y2/:m2' => 'newgen#index'
  # get 'sstainan/:profile_id' => 'sstainan#index'
  get 'sstainan' => 'sstainan#index'
  get 'sstainan/send_mail' => 'sstainan#send_mail'
  get 'sstainan/download' => 'sstainan#download'

  get 'sunmailife' => 'sunmailife#index'
  get 'sunmailife/download' => 'sunmailife#download'

  get 'matrixec' => 'matrixec#index'
  post 'matrixec' => 'matrixec#post'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
