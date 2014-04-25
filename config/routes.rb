Ad2l::Application.routes.draw do

  get "welcome/index"
  resources :seasons, :only => [:index, :show]
  get "schedule" => 'seasons#index'
  resources :teams do
    member do
      match 'players' => 'teams#add_players', :via => :post
      match 'players'  => 'teams#remove_players', :via => :delete
    end
  end
  resources :matches
  resources :posts
  resources :players, :only => [:new, :index, :show, :update] do
    member do
      match 'endorse' => 'players#endorse', :via => :post
    end
  end
  post 'auth/steam/callback' => 'welcome#auth_callback'
  get 'welcome/contact' => 'welcome#contact'
  get 'welcome/community' => 'welcome#community'
  get 'welcome/faq' => 'welcome#faq'
  get 'logout' => 'welcome#logout'
  post 'top_plays_email' => 'welcome#top_plays_email'

  get 'matchcommentspartial' => 'matches#match_comments_partial'
  post 'matchcomment' => 'matches#create_match_comment'
  post 'matchcomment_delete' => 'matches#delete_match_comment'

  post 'add_player' => 'teams#add_player'

  get 'player_comments_partial' => 'players#player_comments_partial'
  post 'player_comment' => 'players#create_player_comment'
  post 'player_comment_delete' => 'players#delete_player_comment'

  get 'admin/players' => 'admin#players'

  scope '/admin' do
    root :to => "admin#index"
    get "manage_seasons(/:season(/:week))" => 'admin#manage_seasons'
  end


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
