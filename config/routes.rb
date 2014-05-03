Ad2l::Application.routes.draw do

  get "welcome/index"
  resources :seasons, :only => [:create, :update, :index, :show] do
    member do
      match 'manage' => "seasons#manage"
      match 'setup_challonge' => "challonge#setup"
      match 'sync_challonge_matches' => "challonge#sync_matches"
      match 'launch_challonge' => "challonge#launch"
      match 'rebuild_challonge' => "challonge#rebuild"
    end
  end




  resources :register

  get "schedule" => 'seasons#index'

  resources :teams do
    member do
      match 'players' => 'teams#add_players', :via => :post
      match 'players'  => 'teams#remove_players', :via => :delete
    end
  end

  resources :team_seasons, :only => [:create, :show, :update, :destroy]
  resources :matches
  resources :posts

  resources :players, :only => [:new, :index, :show, :update] do
    member do
      match 'endorse' => 'players#endorse', :via => :post
    end
  end

  post 'auth/steam/callback' => 'welcome#auth_callback'
  get 'contact', :to => 'welcome#contact', :as => 'contact'
  get 'community', :to => 'welcome#community', :as => 'community'
  get 'faq', :to => 'welcome#faq', :as => 'faq'
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



  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
