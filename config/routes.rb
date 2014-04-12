Ad2l::Application.routes.draw do

  get "welcome/index"
  resources :seasons, :only => [:index, :show]
  get "schedule" => 'seasons#index'
  resources :teams
  resources :matches
  resources :posts
  resources :players, :only => [:new, :index, :show, :update]
  post 'auth/steam/callback' => 'welcome#auth_callback'
  get 'welcome/contact' => 'welcome#contact'
  get 'welcome/community' => 'welcome#community'
  get 'logout' => 'welcome#logout'
  post 'matchcomment' => 'matches#create_match_comment'
  post 'matchcomment_delete' => 'matches#delete_match_comment'
  get 'matchcommentspartial' => 'matches#match_comments_partial'
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
